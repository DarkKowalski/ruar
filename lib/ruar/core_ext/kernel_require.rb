# frozen_string_literal: true

module Ruar
  class Access
    module CoreExt
      def self.make_load_error(path)
        err = LoadError.new(+"cannot load such file -- #{path}")
        err.define_singleton_method(:path) { path }
        err
      end

      # Generate pseudo $LOADED_FEATURES entry
      def self.pseudo_lf_entry(path)
        prefix = '/from/ruar/internal/'
        File.join(prefix, path)
      end
    end
  end
end

module Kernel
  module_function

  alias require_without_ruar require

  def require_with_ruar(path)
    pseudo_entry = Ruar::Access::CoreExt.pseudo_lf_entry(path)
    return false if $LOADED_FEATURES.include?(pseudo_entry) # Already been required

    begin
      Ruar.eval(path)
      $LOADED_FEATURES << pseudo_entry
      true
    rescue Ruar::Error::FileNotFound
      begin
        Ruar.eval("#{path}.rb") # Try again with .rb extension
        $LOADED_FEATURES << pseudo_entry
        true
      rescue Ruar::Error::FileNotFound
        raise Ruar::Access::CoreExt.make_load_error(path)
      end
    end
  end

  def require(path, option = { from: :both })
    case option[:from]
    when :both
      begin
        require_with_ruar(path)
      rescue LoadError
        require_without_ruar(path)
      end
    when :ruar
      require_with_ruar(path)
    when :local
      require_without_ruar(path)
    else
      warn "#{__FILE__}:#{__LINE__}: unknown option: #{option}"
      raise Ruar::Access::CoreExt.make_load_error(path)
    end
  end
end
