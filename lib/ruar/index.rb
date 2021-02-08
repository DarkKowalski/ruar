# frozen_string_literal: true

module Ruar
  class Index
    attr_reader :dir, :index, :source_info

    def initialize(dir = '.')
      @dir = dir
      @index = nil
      @source_info = nil
      generate(dir)
    end

    def json_index
      @index.to_json
    end

    private

    # Generate json format index
    def generate(dir)
      # JSON.pretty_generate(scan(dir))
      @index, @source_info = scan(dir, 0)
    end

    # FIXME: don't recurse
    # TODO: support compression and encryption
    # Recursively scan the directory
    def scan(dir, offset)
      Dir.chdir(dir) do
        index = { 'files' => {} }
        source_info = [] # { realpath, size, offset }
        entities = Dir['**']
        return [index, source_info, offset] if entities.empty?

        files = entities.select { |f| File.file?(f) }
        files.each do |f|
          size = File.size(f)

          index['files'][f] = {
            'size' => size,
            'offset' => offset,
            'executable' => File.executable?(f)
          }

          source_info.push({
                             'realpath' => File.realpath(f),
                             'size' => size,
                             'offset' => offset
                           })

          offset += size
        end

        dirs = entities.select { |d| File.directory?(d) }
        dirs.each do |d|
          # Notice: need to accumulate offset here
          sub_index, sub_source_info, offset = scan(d, offset)
          index['files'][d] = sub_index
          source_info.concat(sub_source_info)
        end

        [index, source_info, offset]
      end
    end
  end
end
