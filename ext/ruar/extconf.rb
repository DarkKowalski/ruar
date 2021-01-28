# frozen_string_literal: true

require 'mkmf'
$CFLAGS << ' -O3 '
$CFLAGS << ' -std=c17'

create_makefile('ruar/ruar')
