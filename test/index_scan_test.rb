# frozen_string_literal: true

require 'test_helper'

class IndexScanTest < Minitest::Test
  def test_index_generate_can_list_files_and_directories
    # Assert not raise
    index = Ruar::Index.new('./test/sample')
    puts index.json_index
    puts index.source_info
  end
end
