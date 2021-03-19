# frozen_string_literal: true

module Ruar
  class Cipher
    def initialize
      @enable = false
    end

    def aead
      @aead ||= OpenSSL::Cipher.new('aes-256-gcm')
    end

    def enable?
      @enable
    end

    def enable
      @enable = true
    end

    # Use iv for initial vector
    # rubocop:disable Naming/MethodParameterName
    def setup(key: nil, iv: nil, auth_data: nil, tag: nil)
      @key = key.nil? ? aead.random_key : Base64.decode64(key)
      @iv = iv.nil? ? aead.random_iv : Base64.decode64(iv)
      @auth_data = auth_data.nil? ? 'ruar_default_auth_data' : Base64.decode64(auth_data)
      @tag = tag.nil? ? 'ruar_invalid_auth_tag' : Base64.decode64(tag)

      self
    end

    def encrypt(data, auth_data: @auth_data, key: @key, iv: @iv)
      cipher = aead.encrypt
      cipher.key = key
      cipher.iv = iv
      cipher.auth_data = auth_data

      compressed = Ruar::Compression.compress(data)
      encrypted = Base64.encode64(cipher.update(compressed) + cipher.final)
      tag = cipher.auth_tag

      {
        encrypted: encrypted,
        iv: iv,
        key: key,
        tag: tag,
        auth_data: auth_data
      }
    end

    def decrypt(data, auth_data: @auth_data, key: @key, iv: @iv, tag: @tag)
      raise 'tag is truncated!' unless tag.bytesize == 16

      cipher = aead.decrypt
      cipher.key = key
      cipher.iv = iv
      cipher.auth_tag = tag
      cipher.auth_data = auth_data

      decrypted = cipher.update(Base64.decode64(data))
      decompressed = Ruar::Compression.decompress(decrypted)

      { decrypted: decompressed }
    end
    # rubocop:enable Naming/MethodParameterName
  end
end
