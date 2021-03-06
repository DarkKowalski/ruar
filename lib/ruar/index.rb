# frozen_string_literal: true

module Ruar
  class Index
    attr_reader :dir, :index, :source_info

    def initialize(dir = '.')
      @dir = dir
      generate(dir) do |file|
        yield(file) if block_given?
      end
    end

    def json_index
      @index.to_json
    end

    private

    # Generate json format index
    def generate(dir)
      @index, @source_info = scan(dir, 0) do |file|
        yield(file) if block_given?
      end
    end

    # FIXME: don't recurse
    # TODO: support compression and encryption
    # Recursively scan the directory
    # rubocop:disable Metrics/CyclomaticComplexity
    def scan(dir, offset)
      Dir.chdir(dir) do
        index = { 'files' => {} }
        source_info = [] # { realpath, size, offset }
        entities = Dir['**']
        return [index, source_info, offset] if entities.empty?

        files = entities.select { |f| File.file?(f) }
        files.each do |f|
          # Do something else likes encrypting the file
          yield(f) if block_given?

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
        # rubocop:enable Metrics/CyclomaticComplexity

        dirs = entities.select { |d| File.directory?(d) }
        dirs.each do |d|
          # Notice: need to accumulate offset here
          sub_index, sub_source_info, offset = scan(d, offset) do |f|
            yield(f) if block_given?
          end
          index['files'][d] = sub_index
          source_info.concat(sub_source_info)
        end

        [index, source_info, offset]
      end
    end
  end
end
