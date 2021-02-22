# frozen_string_literal: true

module Ruar
  module Setup
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def setup(archive: nil, entry: nil, rien: false)
        @entrypoint ||= Ruar::EntryPoint.new(archive: archive, entry: entry)
        # Rien uses relative path when it compiles the Ruby code
        @path_prefix ||= rien ? Pathname.new('') : Pathname.new('/_from/_ruar/_internal')

        self
      end

      def path_prefix
        @path_prefix
      end

      def activate
        return if @activated

        @activated = true

        require_relative 'core_ext/kernel_require'
        @entrypoint.activate

        puts 'Ruar Activated!'.green
      end

      def eval(path, bind = TOPLEVEL_BINDING)
        @entrypoint.eval(path, bind)
      end

      def read(path)
        @entrypoint.read(path)
      end

      def cipher
        @cipher ||= Ruar::Cipher.new
      end
    end
  end
end

module Ruar
  include Ruar::Setup
end
