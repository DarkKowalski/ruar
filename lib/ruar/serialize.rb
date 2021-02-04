# frozen_string_literal: true

module Ruar
  module Serialize
    def self.plain(srcdir, dstfile)
      index = Ruar::Index.new(srcdir)
      header = Ruar::Serialize::Native.plain_header(dstfile, index.json_index)
      files_start = header['index_start'] + header['index_size']
      index.source_info.each do |src|
        puts src['realpath']
        Ruar::Serialize::Native.append_file(dstfile, src['realpath'])
      end
    end
  end
end
