#include "ruar.h"

#include <ruby.h>
#include <stdint.h>
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
static VALUE ruar_serialize_rb_plain(VALUE self, VALUE srcdir, VALUE dstdir);

/* Ruar::Access::Native */
static VALUE rb_mRuar_Access;
static VALUE rb_mRuar_Access_Native;

/* Functions exposed as module functions on Ruar::Access::Native */
static VALUE ruar_access_rb_header(VALUE self, VALUE archive);
static VALUE ruar_access_rb_index(VALUE self, VALUE archive);
static VALUE ruar_access_rb_file(VALUE self, VALUE archive, VALUE path);

/* Helpers*/
static unsigned long ruar_crc32(const unsigned char *bytes, const int len);
void Init_ruar(void)
{
    rb_mRuar = rb_define_module("Ruar");

    rb_mRuar_Serialize = rb_define_module_under(rb_mRuar, "Serialize");
    rb_mRuar_Serialize_Native = rb_define_module_under(rb_mRuar_Serialize, "Native");

    rb_mRuar_Access = rb_define_module_under(rb_mRuar, "Access");
    rb_mRuar_Access_Native = rb_define_module_under(rb_mRuar_Access, "Native");

    rb_define_module_function(rb_mRuar_Serialize_Native, "plain", ruar_serialize_rb_plain, 0);

    rb_define_module_function(rb_mRuar_Access_Native, "header", ruar_access_rb_header, 0);
    rb_define_module_function(rb_mRuar_Access_Native, "index", ruar_access_rb_index, 0);
    rb_define_module_function(rb_mRuar_Access_Native, "file", ruar_access_rb_file, 0);
}

static VALUE ruar_serialize_rb_plain(VALUE self, VALUE srcdir, VALUE dstdir)
{
    /* FIXME: return nil currenlty */
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
