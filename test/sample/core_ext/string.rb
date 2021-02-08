# frozen_string_literal: true

class String
  def ext
    {
      'env_file' => __FILE__,
      'env_lineno' => __LINE__,
      'real_file' => 'core_ext/string.rb'
    }
  end
end
