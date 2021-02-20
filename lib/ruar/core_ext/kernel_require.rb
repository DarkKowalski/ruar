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
        prefix = Ruar.path_prefix
        # TODO: support .so here
        if File.extname(path) == '.rb'
          File.join(prefix, path)
        else
          File.join(prefix, "#{path}.rb")
        end
      end
    end
  end
end

module Kernel
  module_function

  def ruar_eval_wrap(path, eval_bind = TOPLEVEL_BINDING)
    Ruar.eval("#{path}.rb", eval_bind) # Ruar.eval(path.rb, eval_bind)
    yield
    true
  rescue Ruar::Error::FileNotFound
    # Try again without .rb extension
    begin
      Ruar.eval(path, eval_bind)
      yield
      true
    rescue Ruar::Error::BaseError
      raise Ruar::Access::CoreExt.make_load_error(path)
    end
  rescue Ruar::Error::BaseError
    raise Ruar::Access::CoreExt.make_load_error(path)
  end

  alias require_without_ruar require

  def require_with_ruar(path, eval_bind = TOPLEVEL_BINDING)
    # puts "path = #{path}, location = #{eval_bind.source_location}"
    pseudo_entry = Ruar::Access::CoreExt.pseudo_lf_entry(path)
    return false if $LOADED_FEATURES.include?(pseudo_entry) # Already been required

    ruar_eval_wrap(path, eval_bind) do
      $LOADED_FEATURES << pseudo_entry
    end
  end

  def require(path, from: :both)
    case from
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
      raise Ruar::Access::CoreExt.make_load_error(path)
    end
  end

  alias require_relative_without_ruar require_relative

  # TODO: need to test
  def require_relative(path, from: :both)
    caller_path = caller_locations.first.path.to_s
    caller_dir = Pathname.new(caller_path).dirname.to_s
    prefix = Ruar.path_prefix.to_s

    # Ruar Internal File
    caller_dir = caller_dir.delete_prefix(prefix).prepend(File::SEPARATOR) if caller_dir.start_with?(prefix)

    resolved_path = File.expand_path(path, caller_dir)
    require(resolved_path, from: from)
  end

  alias load_without_ruar load

  def load_with_ruar(path, eval_bind = TOPLEVEL_BINDING)
    ruar_eval_wrap(path, eval_bind) do
      # Do nothing, just read and eval
    end
  end

  def load(path, from: :both)
    case from
    when :both
      begin
        load_with_ruar(path)
      rescue LoadError
        load_without_ruar(path)
      end
    when :ruar
      load_with_ruar(path)
    when :local
      load_without_ruar(path)
    else
      raise Ruar::Access::CoreExt.make_load_error(path)
    end
  end

  # TODO: deliberately test autoload
  # FIXME: not support autoload
end
