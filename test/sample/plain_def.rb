# frozen_string_literal: true

def hello
  {
    'env_file' => __FILE__,
    'env_lineno' => __LINE__,
    'real_file' => 'plain_def.rb'
  }
end
