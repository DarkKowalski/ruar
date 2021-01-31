# frozen_string_literal: true

require 'mkmf'
$CFLAGS << ' -O3 '
$CFLAGS << ' -std=c99'

create_makefile('ruar/ruar')
