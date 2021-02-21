#include "ruar.h"

#include <ctype.h>
#include <ruby.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <zlib.h>

#define HEADER_SIZE 64 /* Bytes */

/* Notice: O(n) */
#define INDEX_SIZE(i) ((uint32_t)(strlen((i)) + 1)) /* Bytes */

#define READ_SRC_BUFFER_SIZE 0x8000 /* Bytes */

struct ruar_header
{
    uint32_t major_version;
    uint32_t minor_version;
    uint32_t patch_version;
    uint32_t platform;
    uint32_t encryption_flags;
    uint32_t compression_flags;
    uint32_t index_start;
    uint32_t index_size;
    uint32_t index_checksum;
    uint32_t header_checksum;
    uint8_t pad[24];
} __attribute__((packed));

/*
 * If the struct padding isn't correct to pad the key to 64 bytes, 
 * refuse to compile.
 */
#define STATIC_ASSERT(X) STATIC_ASSERT2(X, __LINE__)
#define STATIC_ASSERT2(X, L) STATIC_ASSERT3(X, L)
#define STATIC_ASSERT3(X, L) STATIC_ASSERT_MSG(X, at_line_##L)
#define STATIC_ASSERT_MSG(COND, MSG) typedef char static_assertion_##MSG[(!!(COND)) * 2 - 1]
STATIC_ASSERT(sizeof(struct ruar_header) == HEADER_SIZE);

/* Constants */
static const uint32_t current_major_version = 0;
static const uint32_t current_minor_version = 0;
static const uint32_t current_patch_version = 3;

/* Flags */
#define PLAIN 0
#define AEAD_AES_256_GCM 1
#define ZLIB_DEFLATE 1

/* System info */
#ifdef __linux__
static uint32_t current_platform = 1;
#elif __APPLE__
static uint32_t current_platform = 2;
#elif BSD
static uint32_t current_platform = 3;
#elif __CYGWIN__
static uint32_t current_platform = 4;
#elif __WIN32
static uint32_t current_platform = 5;
#else
static uint32_t current_platform = 0;
#endif

/* Ruar::Serialize::Native */
static VALUE rb_mRuar;
static VALUE rb_mRuar_Serialize;
static VALUE rb_mRuar_Serialize_Native;

/* Functions exposed as module functions on Ruar::Serialize::Native */
static VALUE ruar_serialize_rb_plain_header(VALUE self, VALUE dstfile, VALUE index);
static VALUE ruar_serialize_rb_aead_header(VALUE self, VALUE dstfile, VALUE index);
static VALUE ruar_serialize_rb_append_file(VALUE self, VALUE dstfile, VALUE srcfile);

/* Ruar::Access::Native */
static VALUE rb_kRuar_Access;
static VALUE rb_mRuar_Access_Native;

/* Functions exposed as instance method on Ruar::Access::Native */
static VALUE ruar_access_rb_header(VALUE self, VALUE archive);
static VALUE ruar_access_rb_index(VALUE self, VALUE archive);
static VALUE ruar_access_rb_file(VALUE self, VALUE archive, VALUE offset, VALUE size);

/* Ruar::Const::Native */
static VALUE rb_mRuar_Const;
static VALUE rb_mRuar_Const_Native;

/* Functions exposed as module functions on Ruar::Const::Native */
static VALUE ruar_const_rb_header_size(VALUE self);

/* Helpers*/
static uint32_t ruar_crc32_generate(const unsigned char *bytes, const int len);
static VALUE ruar_rb_header_hash(const struct ruar_header *header);

void Init_ruar(void)
{
    rb_mRuar = rb_define_module("Ruar");

    rb_mRuar_Serialize = rb_define_module_under(rb_mRuar, "Serialize");
    rb_mRuar_Serialize_Native = rb_define_module_under(rb_mRuar_Serialize, "Native");
    rb_define_module_function(rb_mRuar_Serialize_Native, "plain_header", ruar_serialize_rb_plain_header, 2);
    rb_define_module_function(rb_mRuar_Serialize_Native, "aead_header", ruar_serialize_rb_aead_header, 2);
    rb_define_module_function(rb_mRuar_Serialize_Native, "append_file", ruar_serialize_rb_append_file, 2);

    rb_kRuar_Access = rb_define_class_under(rb_mRuar, "Access", rb_cObject);
    rb_mRuar_Access_Native = rb_define_module_under(rb_kRuar_Access, "Native");
    rb_define_module_function(rb_mRuar_Access_Native, "header", ruar_access_rb_header, 1);
    rb_define_module_function(rb_mRuar_Access_Native, "index", ruar_access_rb_index, 1);
    rb_define_module_function(rb_mRuar_Access_Native, "file", ruar_access_rb_file, 3);

    rb_mRuar_Const = rb_define_module_under(rb_mRuar, "Const");
    rb_mRuar_Const_Native = rb_define_module_under(rb_mRuar_Const, "Native");
    rb_define_module_function(rb_mRuar_Const_Native, "header_size", ruar_const_rb_header_size, 0);
}

static VALUE ruar_const_rb_header_size(VALUE self)
{
    return INT2NUM(HEADER_SIZE);
}

static uint32_t ruar_crc32_generate(const unsigned char *bytes, const int len)
{
    return crc32(0, bytes, len) & 0xffffffff;
}

static VALUE ruar_rb_header_hash(const struct ruar_header *header)
{
    VALUE rb_header = rb_hash_new();

    rb_hash_aset(rb_header, rb_utf8_str_new_cstr("major_version"), INT2NUM(header->major_version));
    rb_hash_aset(rb_header, rb_utf8_str_new_cstr("minor_version"), INT2NUM(header->minor_version));
    rb_hash_aset(rb_header, rb_utf8_str_new_cstr("patch_version"), INT2NUM(header->patch_version));
    rb_hash_aset(rb_header, rb_utf8_str_new_cstr("platform"), INT2NUM(header->platform));
    rb_hash_aset(rb_header, rb_utf8_str_new_cstr("compression_flags"), INT2NUM(header->compression_flags));
    rb_hash_aset(rb_header, rb_utf8_str_new_cstr("encrypthon_flags"), INT2NUM(header->encryption_flags));
    rb_hash_aset(rb_header, rb_utf8_str_new_cstr("index_start"), INT2NUM(header->index_start));
    rb_hash_aset(rb_header, rb_utf8_str_new_cstr("index_size"), INT2NUM(header->index_size));
    rb_hash_aset(rb_header, rb_utf8_str_new_cstr("index_checksum"), INT2NUM(header->index_checksum));
    rb_hash_aset(rb_header, rb_utf8_str_new_cstr("header_checksum"), INT2NUM(header->header_checksum));

    return rb_header;
}

static struct ruar_header ruar_fillout_header(char *index_cstring, uint32_t index_size, uint32_t encryption_flags, uint32_t compression_flags)
{
    /* Fill out a header */
    struct ruar_header header = {
        .major_version = current_major_version,
        .minor_version = current_minor_version,
        .patch_version = current_patch_version,
        .platform = current_platform,
        .encryption_flags = encryption_flags,
        .compression_flags = compression_flags,
        .index_start = HEADER_SIZE,
        .index_size = index_size,
        .index_checksum = ruar_crc32_generate((unsigned char *)index_cstring, index_size),
        .header_checksum = 0};
    header.header_checksum = ruar_crc32_generate((unsigned char *)&header, HEADER_SIZE);

    return header;
}

static bool ruar_write_header_to_file(char *dstfile_cstring, char *index_cstring, uint32_t index_size, struct ruar_header *header)
{
    FILE *outfile = fopen(dstfile_cstring, "wb");
    if (outfile == NULL)
    {
        fprintf(stderr, "\nFailed to open file! %s\n", dstfile_cstring);
        return false;
    }

    fwrite(header, HEADER_SIZE, 1, outfile);
    fwrite(index_cstring, index_size, 1, outfile);
    fclose(outfile);
    return true;
}

static VALUE ruar_serialize_rb_plain_header(VALUE self, VALUE dstfile, VALUE index)
{
    char *index_cstring = rb_string_value_cstr(&index);
    uint32_t index_size = INDEX_SIZE(index_cstring);

    /* Fill out a header */
    struct ruar_header header = ruar_fillout_header(index_cstring, index_size, PLAIN, PLAIN);

    /* Write header */
    char *dstfile_cstring = rb_string_value_cstr(&dstfile);
    if (!ruar_write_header_to_file(dstfile_cstring, index_cstring, index_size, &header))
    {
        return Qnil;
    }

    /* Get Ruby Hash */
    return ruar_rb_header_hash(&header);
}

static VALUE ruar_serialize_rb_aead_header(VALUE self, VALUE dstfile, VALUE index)
{
    /* Index should be encrypted in Ruby land */
    char *index_cstring = rb_string_value_cstr(&index);
    uint32_t index_size = INDEX_SIZE(index_cstring);

    /* Fill out a header */
    struct ruar_header header = ruar_fillout_header(index_cstring, index_size, AEAD_AES_256_GCM, ZLIB_DEFLATE);

    /* Write header */
    char *dstfile_cstring = rb_string_value_cstr(&dstfile);
    if (!ruar_write_header_to_file(dstfile_cstring, index_cstring, index_size, &header))
    {
        return Qnil;
    }

    /* Get Ruby Hash */
    return ruar_rb_header_hash(&header);
}

/* FIXME: maybe we need an atomic way to do this */
static VALUE ruar_serialize_rb_append_file(VALUE self, VALUE dstfile, VALUE srcfile)
{
    /* Open archive file to write */
    char *dstfile_cstring = rb_string_value_cstr(&dstfile);
    FILE *outfile = fopen(dstfile_cstring, "ab");
    if (outfile == NULL)
    {
        fprintf(stderr, "\nFailed to open file! %s\n", dstfile_cstring);
        return Qnil;
    }

    /* Open source file to read */
    char *srcfile_cstring = rb_string_value_cstr(&srcfile);
    FILE *sourcefile = fopen(srcfile_cstring, "rb");
    if (sourcefile == NULL)
    {
        fprintf(stderr, "\nFailed to open file! %s\n", dstfile_cstring);
        fclose(outfile);
        return Qnil;
    }

    /* Append source to archive */
    uint8_t buf[READ_SRC_BUFFER_SIZE];
    size_t size = 0;
    while ((size = fread(buf, 1, READ_SRC_BUFFER_SIZE, sourcefile)))
    {
        // fprintf(stdout, "Write %d bytes, from %s to %s\n", size, srcfile_cstring, dstfile_cstring);
        fwrite(buf, 1, size, outfile);
    }

    /* Clean up */
    fclose(sourcefile);
    fclose(outfile);

    /* Ruby Hash */
    return srcfile;
}

static VALUE ruar_access_rb_header(VALUE self, VALUE archive)
{
    char *archive_cstring = rb_string_value_cstr(&archive);
    FILE *fp = fopen(archive_cstring, "rb");
    if (fp == NULL)
    {
        fprintf(stderr, "\nFailed to open file! %s\n", archive_cstring);
        return Qnil;
    }
    uint8_t buf[HEADER_SIZE];
    fread(buf, HEADER_SIZE, 1, fp);
    fclose(fp);

    struct ruar_header *header = (struct ruar_header *)buf;

    /* Validate */
    uint32_t header_checksum = header->header_checksum;           /* Extract first*/
    header->header_checksum = 0;                                  /* Clear these bits */
    uint32_t re_checksum = ruar_crc32_generate(buf, HEADER_SIZE); /* Re-compute it */
    header->header_checksum = header_checksum;                    /* Put it back */
    if (re_checksum != header_checksum)
    {
        fprintf(stderr, "\nUnmatched checksum, provided: %x, expected: %x \n", re_checksum, header_checksum);
        return Qnil;
    }

    /* Ruby Hash */
    return ruar_rb_header_hash(header);
}

static VALUE ruar_access_rb_index(VALUE self, VALUE archive)
{
    /* Read the header first */
    char *archive_cstring = rb_string_value_cstr(&archive);
    FILE *fp = fopen(archive_cstring, "rb");
    if (fp == NULL)
    {
        fprintf(stderr, "\nFailed to open file! %s\n", archive_cstring);
        return Qnil;
    }

    uint8_t header_buf[HEADER_SIZE];
    fread(header_buf, HEADER_SIZE, 1, fp);

    /* Extract index info from the header */
    struct ruar_header *header = (struct ruar_header *)header_buf;
    uint32_t index_start = header->index_start;
    uint32_t index_size = header->index_size;
    uint32_t index_checksum = header->index_checksum;

    /* Prepare buffer and load the index into memory 
     * When we serialized the index into archive, the trailing '\0'
     * has already been added and counted in index_size
     */
    uint8_t *index_buf = (uint8_t *)malloc(sizeof(uint8_t) * index_size);
    if (index_buf == NULL)
    {
        fprintf(stderr, "\nFailed to allocate memory for index buffer!\n");
        fclose(fp);
        return Qnil;
    }
    fseek(fp, index_start, SEEK_SET);
    fread(index_buf, index_size, 1, fp);
    fclose(fp);

    /* Validate */
    uint32_t re_checksum = ruar_crc32_generate(index_buf, index_size);
    if (re_checksum != index_checksum)
    {
        free(index_buf);
        fprintf(stderr, "\nUnmatched checksum, provided: %x, expected: %x \n", re_checksum, index_checksum);
        return Qnil;
    }

    /* Get Ruby String */
    VALUE index = rb_utf8_str_new_cstr((char *)index_buf);
    free(index_buf);

    /* Ruby String */
    return index;
}

/* Offset here is absolute offset from the beginning of the archive,
 * and it's calculated in Ruby code
 */
static VALUE ruar_access_rb_file(VALUE self, VALUE archive, VALUE offset, VALUE size)
{
    char *archive_cstring = rb_string_value_cstr(&archive);
    FILE *fp = fopen(archive_cstring, "rb");
    if (fp == NULL)
    {
        fprintf(stderr, "\nFailed to open file! %s\n", archive_cstring);
        return Qnil;
    }

    size_t size_cint = NUM2SIZET(size);

    /* Ruby C API will convert this C-style String to a Ruby String Object
     * Thus one extra byte for the trialing '\0' 
     */
    uint8_t *file_buf = (uint8_t *)malloc(sizeof(uint8_t) * size_cint + 1);
    if (file_buf == NULL)
    {
        fprintf(stderr, "\nFailed to allocate memory for file buffer!\n");
        fclose(fp);
        return Qnil;
    }

    size_t offset_cint = NUM2SIZET(offset);
    fseek(fp, offset_cint, SEEK_SET);
    fread(file_buf, 1, size_cint, fp);
    fclose(fp);

    /* Trailing '\0' for the C-style string */
    file_buf[size_cint] = '\0';
    VALUE file = rb_utf8_str_new_cstr((char *)file_buf);
    free(file_buf);

    /* Ruby String */
    return file;
}
