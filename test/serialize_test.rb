# frozen_string_literal: true

require 'test_helper'

class SerializeTest < Minitest::Test
  def test_ruar_can_serialize_file_using_plain_mode
    Ruar::Serialize.plain('./test/sample', '/tmp/plain.ruar')
    # puts header_hex = `head -c 64 /tmp/plain.ruar | hexdump -C `
  end
end
