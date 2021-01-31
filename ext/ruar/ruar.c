#include "ruar.h"

#include <ctype.h>
#include <ruby.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <zlib.h>

#define HEADER_SIZE 64 /* Bytes */

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
static const uint32_t current_patch_version = 1;

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
static VALUE ruar_serialize_rb_plain(VALUE self, VALUE srcdir, VALUE dstfile);

/* Ruar::Access::Native */
static VALUE rb_mRuar_Access;
static VALUE rb_mRuar_Access_Native;

/* Functions exposed as module functions on Ruar::Access::Native */
static VALUE ruar_access_rb_header(VALUE self, VALUE archive);
static VALUE ruar_access_rb_index(VALUE self, VALUE archive);
static VALUE ruar_access_rb_file(VALUE self, VALUE archive, VALUE path);

/* Helpers*/
static uint32_t ruar_crc32_generate(const unsigned char *bytes, const int len);
static char *ruar_index_scan(const VALUE srcdir);

void Init_ruar(void)
{
    rb_mRuar = rb_define_module("Ruar");

    rb_mRuar_Serialize = rb_define_module_under(rb_mRuar, "Serialize");
    rb_mRuar_Serialize_Native = rb_define_module_under(rb_mRuar_Serialize, "Native");

    rb_mRuar_Access = rb_define_module_under(rb_mRuar, "Access");
    rb_mRuar_Access_Native = rb_define_module_under(rb_mRuar_Access, "Native");

    rb_define_module_function(rb_mRuar_Serialize_Native, "plain", ruar_serialize_rb_plain, 2);

    rb_define_module_function(rb_mRuar_Access_Native, "header", ruar_access_rb_header, 1);
    rb_define_module_function(rb_mRuar_Access_Native, "index", ruar_access_rb_index, 1);
    rb_define_module_function(rb_mRuar_Access_Native, "file", ruar_access_rb_file, 2);
}

static uint32_t ruar_crc32_generate(const unsigned char *bytes, const int len)
{
    return crc32(0, bytes, len) & 0xffffffff;
}

/* FIXME: use rb_protect instead */
static char *ruar_index_scan(const VALUE srcdir)
{
    VALUE rb_mRuar_Index = rb_const_get(rb_mRuar, rb_intern("Index"));
    VALUE index = rb_funcall(rb_mRuar_Index, rb_intern("generate"), 1, srcdir);

    return rb_string_value_cstr(&index);
}

static VALUE ruar_serialize_rb_plain(VALUE self, VALUE srcdir, VALUE dstfile)
{
    /* FIXME: return nil currenlty */
    char *index = ruar_index_scan(srcdir);
    int index_size = strlen(index) + 1;

    struct ruar_header header = {
        .major_version = current_major_version,
        .minor_version = current_minor_version,
        .patch_version = current_patch_version,
        .platform = current_platform,
        .encryption_flags = 0,
        .compression_flags = 0,
        .index_start = HEADER_SIZE,
        .index_size = index_size,
        .index_checksum = ruar_crc32_generate((unsigned char *)index, index_size),
        .header_checksum = 0};
    header.header_checksum = ruar_crc32_generate((unsigned char *)&header, HEADER_SIZE);

    char *dstfile_cstring = rb_string_value_cstr(&dstfile);
    FILE *outfile = fopen(dstfile_cstring, "w");
    if (outfile == NULL)
    {
        fprintf(stderr, "\nFailed to open file!%s\n", dstfile_cstring);
        free(dstfile_cstring);
        return Qnil;
    }

    fwrite(&header, HEADER_SIZE, 1, outfile);
    fwrite(index, index_size, 1, outfile);
    fclose(outfile);

    return Qnil;
}

static VALUE ruar_access_rb_header(VALUE self, VALUE archive)
{
    /* FIXME: return nil currenlty */
    return Qnil;
}
static VALUE ruar_access_rb_index(VALUE self, VALUE archive)
{
    /* FIXME: return nil currenlty */
    return Qnil;
}
static VALUE ruar_access_rb_file(VALUE self, VALUE archive, VALUE path)
{
    /* FIXME: return nil currenlty */
    return Qnil;
}
