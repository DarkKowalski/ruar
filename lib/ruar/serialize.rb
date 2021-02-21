# frozen_string_literal: true

module Ruar
  module Serialize
    def self.plain(srcdir, dstfile)
      index = Ruar::Index.new(srcdir)
      Ruar::Serialize::Native.plain_header(dstfile, index.json_index)
      index.source_info.each do |src|
        Ruar::Serialize::Native.append_file(dstfile, src['realpath'])
      end
    end

    def self.aead(srcdir, dstfile)
      time = Time.now.strftime('%Y%m%dT%H%M')
      tmpdir = File.expand_path("ruar_#{time}", Dir.tmpdir)
      FileUtils.copy_entry(srcdir, tmpdir)

      encryption_info = nil
      index = Ruar::Index.new(tmpdir) do |file|
        data = File.read(file)
        encryption_info = Ruar.cipher.encrypt(data)
        File.write(file, encryption_info[:encrypted])
      end

      encrypted_index = Ruar.cipher.encrypt(index.json_index)[:encrypted]
      Ruar::Serialize::Native.aead_header(dstfile, encrypted_index)

      index.source_info.each do |src|
        Ruar::Serialize::Native.append_file(dstfile, src['realpath'])
      end

      setup_file = <<~SETUP
        Ruar.cipher.setup(
          iv: '#{Base64.encode64(encryption_info[:iv]).chomp}',
          key: '#{Base64.encode64(encryption_info[:key]).chomp}',
          auth_data: '#{Base64.encode64(encryption_info[:auth_data]).chomp}',
          tag: '#{Base64.encode64(encryption_info[:tag]).chomp}')
        Ruar.cipher.enable
      SETUP

      File.write("#{dstfile}.setup", setup_file)

      FileUtils.rm_rf(tmpdir)
    end
  end
end
