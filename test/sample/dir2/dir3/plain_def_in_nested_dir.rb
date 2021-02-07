# frozen_string_literal: true

def plain_def_in_nested_dir
  {
    'env_file' => __FILE__,
    'env_lineno' => __LINE__,
    'real_file' => 'dir2/dir3/plain_def_in_dir.rb'
  }
end
