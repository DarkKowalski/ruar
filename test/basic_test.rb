# frozen_string_literal: true

require 'test_helper'

class BasicTest < Minitest::Test
  def test_ruar_can_be_initialized
    # Assert not raise
    Ruar::Const::Native.header_size
  end
end
