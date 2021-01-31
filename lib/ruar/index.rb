# frozen_string_literal: true

module Ruar
  module Index
    # Generate json format index
    def self.generate(dir)
      # JSON.pretty_generate(scan(dir))
      scan(dir).to_json
    end

    # Recursively scan the directory
    def self.scan(dir)
      Dir.chdir(dir) do
        result = { 'files' => {} }
        entities = Dir['**']
        return result if entities.empty?

        files = entities.select { |f| File.file?(f) }
        files.each do |f|
          result['files'][f] = {
            'size' => File.size(f),
            'executable' => File.executable?(f)
          }
        end

        dirs = entities.select { |d| File.directory?(d) }
        dirs.each { |d| result['files'][d] = scan(d) }

        result
      end
    end
  end
end
