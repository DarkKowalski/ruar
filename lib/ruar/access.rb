# frozen_string_literal: true

module Ruar
  class Access
    attr_reader :archive, :header, :index

    def self.make_not_exist_error(path)
      Ruar::Error::FileNotFound.new(path)
    end

    def initialize(archive)
      @archive = archive
      rebuild
    end

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

    def eval(path)
      pseudo_filename = Ruar::Access.abs_path(path)
      pseudo_lineno = 1
      file = read(path)
      # FIXME: need to test
      Kernel.eval(file, TOPLEVEL_BINDING, pseudo_filename, pseudo_lineno)
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
