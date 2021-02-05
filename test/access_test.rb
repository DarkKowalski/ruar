# frozen_string_literal: true

require 'test_helper'

class AccessTest < Minitest::Test
  def setup
    @archive = File.join(Dir.tmpdir, 'plain.ruar')
    Ruar::Serialize.plain('./test/sample', @archive)
    @access = Ruar::Access.new(@archive)
  end

  def test_ruar_can_read_archive_header_using_plain_mode
    refute_nil(@access.header)
  end

  def test_ruar_can_read_archive_index_using_plain_mode
    refute_nil(@access.index)
  end

  def test_ruar_can_resolve_nested_path
    expected = %w[sample y z]
    result = Ruar::Access.clean_path('sample/x/../y/z')
    assert_equal(expected, result)
  end

  def test_ruar_can_lookup_index_from_file_using_plain_mode
    offset, _size, _executable = @access.lookup('./y/z.rb')
    refute_nil(offset)
  end

  def test_ruar_can_read_file_using_plain_mode
    file_content = @access.read('./y/z.rb')
    refute_nil(file_content)
  end

  def test_ruar_can_eval_file_using_plain_mode
    file_content = @access.read('./y/z.rb')
    puts file_content
    Kernel.eval(file_content)
    z
  end
end
