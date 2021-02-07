# frozen_string_literal: true

module Rien
  class Sample
    def hello
      {
        'env_file' => __FILE__,
        'env_lineno' => __LINE__,
        'real_file' => 'module_class.rb'
      }
    end
  end
end
