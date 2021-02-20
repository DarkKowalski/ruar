# frozen_string_literal: true

module Ruar
  class Access
    attr_reader :archive, :header, :index

    def self.make_not_exist_error(path)
      Ruar::Error::FileNotFound.new(path)
    end

    def self.make_failed_to_eval_error(path)
      Ruar::Error::FailedToEval.new(path)
    end

    def self.warn_autoload(name_error)
      location = name_error.backtrace_locations.first
      message = <<~MSG
        #{location}
        Kernel.autoload and Module.autoload are not supported by ruar,
        if you are using them, try `require` instead
      MSG
      warn message.yellow
    end

    def initialize(archive)
      @archive = archive
      rebuild
    end

    # TODO: Need to deliberately test this part
    def lookup(path)
      paths = Ruar::Access.clean_path(path)
      filename = paths.pop

      pwd = @index['files']

      begin
        paths.each { |dir| pwd = pwd[dir]['files'] }
      rescue StandardError
        raise Ruar::Access.make_not_exist_error(path)
      end

      raise Ruar::Access.make_not_exist_error(path) if pwd[filename].nil?

      offset = pwd[filename]['offset'] + @file_start
      size = pwd[filename]['size']
      executable = pwd[filename]['executable']

      [offset, size, executable]
    end

    def read(path)
      offset, size, _executable = lookup(path)
      Ruar::Access::Native.file(@archive, offset.to_i, size.to_i)
    end

    def eval(path, eval_bind = TOPLEVEL_BINDING)
      pseudo_filename = File.join(Ruar.path_prefix.to_s, Ruar::Access.abs_path(path))
      pseudo_lineno = 1
      file = read(path)
      # FIXME: need to test
      begin
        Kernel.eval(file, eval_bind, pseudo_filename, pseudo_lineno)
      rescue NameError => e # FIXME: to warn autoload pitfall
        begin
          Ruar::Access.warn_autoload(e)
          raise
        rescue StandardError
          raise Ruar::Access.make_failed_to_eval_error(path)
        end
      end
    end

    def self.abs_path(path)
      Pathname.new(path).cleanpath.to_s
    end

    # Array
    def self.clean_path(path)
      cleaned = Ruar::Access.abs_path(path).split(File::SEPARATOR)
      cleaned.delete('')

      cleaned
    end

    private

    def rebuild
      @header = Ruar::Access::Native.header(@archive)
      @index = JSON.parse(Ruar::Access::Native.index(@archive))
      @file_start = @header['index_start'] + @header['index_size']
    end
  end
end
