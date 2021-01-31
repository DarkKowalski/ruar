# frozen_string_literal: true

module Ruar
  module Serialize
    def self.plain(srcdir, dstfile)
      #index = Ruar::Index.generate(dir)
      #index_size = index.bytes.size
      #header_size = Ruar::Serialize::Native.header_size
      Ruar::Serialize::Native.plain(srcdir, dstfile)
    end
  end
end
