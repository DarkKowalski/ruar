# frozen_string_literal: true

require 'test_helper'

class BasicTest < Minitest::Test
  def test_ruar_can_be_initialized
    # FIXME: assert nil just for now
    assert_nil(Ruar::Serialize::Native.plain)
  end
end
