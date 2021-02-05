# frozen_string_literal: true

module Ruar
  class Access
    attr_reader :archive, :header, :index

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
        warn "File Not Exist! #{path} resolved to #{paths} -> #{filename}"
        return
      end

      if pwd[filename].nil?
        warn "File Not Exist! #{path} resolved to #{paths} -> #{filename}"
        return
      end

      offset = pwd[filename]['offset'] + @file_start
      size = pwd[filename]['size']
      executable = pwd[filename]['executable']

      [offset, size, executable]
    end

    def read(path)
      offset, size, _executable = lookup(path)
      Ruar::Access::Native.file(@archive, offset.to_i, size.to_i)
    end

    def self.abs_path(path)
      File.expand_path(path, '/')
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
