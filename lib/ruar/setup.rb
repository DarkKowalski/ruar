# frozen_string_literal: true

module Ruar
  module Setup
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def setup(archive: nil, entry: nil)
        @entrypoint ||= Ruar::EntryPoint.new(archive: archive, entry: entry)
        @path_prefix ||= Pathname.new('/_from/_ruar/_internal')

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
    end
  end
end

module Ruar
  include Ruar::Setup
end
