# frozen_string_literal: true

require 'test_helper'

class IndexScanTest < Minitest::Test
  def test_index_generate_can_list_files_and_directories
    # Assert not raise
    puts Ruar::Index.generate('.')
  end
end
