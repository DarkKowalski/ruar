# frozen_string_literal: true

def err
  raise({
    'env_file' => __FILE__,
    'env_lineno' => __LINE__,
    'real_file' => 'y/err.rb'
  }.to_s)
end
