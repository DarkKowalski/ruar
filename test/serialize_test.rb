# frozen_string_literal: true

require 'test_helper'

class SerializeTest < Minitest::Test
  def test_ruar_can_serialize_file_using_plain_mode
    archive = File.join(Dir.tmpdir, 'plain.ruar')
    Ruar::Serialize.plain('./test/sample', archive)
    # puts header_hex = `head -c 64 /tmp/plain.ruar | hexdump -C `
  end
end
