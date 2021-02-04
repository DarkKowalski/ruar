# frozen_string_literal: true

module Ruar
  module Serialize
    def self.plain(srcdir, dstfile)
      index = Ruar::Index.new(srcdir)
      Ruar::Serialize::Native.plain_header(dstfile, index.json_index)
      index.source_info.each do |src|
        puts src['realpath']
        Ruar::Serialize::Native.append_file(dstfile, src['realpath'])
      end
    end
  end
end
