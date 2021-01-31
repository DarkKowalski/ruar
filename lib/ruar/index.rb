# frozen_string_literal: true

module Ruar
  module Index
    # Generate json format index
    def self.generate(dir)
      # JSON.pretty_generate(scan(dir))
      scan(dir, 0).to_json
    end

    # FIXME：don't recurse
    # Recursively scan the directory
    def self.scan(dir, offset)
      Dir.chdir(dir) do
        result = { 'files' => {} }
        entities = Dir['**']
        return result if entities.empty?

        files = entities.select { |f| File.file?(f) }
        files.each do |f|
          size = File.size(f)
          result['files'][f] = {
            'size' => size,
            'offset' => offset,
            'executable' => File.executable?(f)
          }
          offset += size
        end

        dirs = entities.select { |d| File.directory?(d) }
        dirs.each { |d| result['files'][d] = scan(d, offset) }

        result
      end
    end
  end
end
