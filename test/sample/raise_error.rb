# frozen_string_literal: true

def raise_error
  raise({
    'env_file' => __FILE__,
    'env_lineno' => __LINE__,
    'real_file' => 'raise_error.rb'
  }.to_s)
end
