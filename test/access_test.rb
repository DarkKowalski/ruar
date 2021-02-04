# frozen_string_literal: true

require 'test_helper'

class AccessTest < Minitest::Test
  def test_ruar_can_read_archive_header_using_plain_mode
    archive = File.join(Dir.tmpdir, 'plain.ruar')
    Ruar::Serialize.plain('./test/sample', archive)
    access = Ruar::Access.new(archive)
    refute_nil(access.header)
  end

  def test_ruar_can_read_archive_index_using_plain_mode
    archive = File.join(Dir.tmpdir, 'plain.ruar')
    Ruar::Serialize.plain('./test/sample', archive)
    access = Ruar::Access.new(archive)
    refute_nil(access.index)
  end
end
