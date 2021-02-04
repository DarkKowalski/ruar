# frozen_string_literal: true

require 'mkmf'
$CFLAGS << ' -O3 '
$CFLAGS << ' -std=c99'

return unless have_library('z') && have_header('zlib.h') && have_func('crc32', 'zlib.h')

create_makefile('ruar/ruar')
