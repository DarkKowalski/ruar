# frozen_string_literal: true

require 'test_helper'

class AccessTest < Minitest::Test
  def test_ruar_can_read_archive_header_using_plain_mode
    access = Ruar::Access.new('./tmp/plain.ruar')
    puts access.header
  end

  def test_ruar_can_read_archive_index_using_plain_mode
    access = Ruar::Access.new('./tmp/plain.ruar')
    puts access.index
  end
end
