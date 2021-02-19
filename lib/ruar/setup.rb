# frozen_string_literal: true

module Ruar
  module Setup
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def setup(option = {})
        @entrypoint ||= Ruar::EntryPoint.new(option)
        @path_prefix ||= Pathname.new('/_from/_ruar/_internal')

        self
      end

      def path_prefix
        @path_prefix
      end

      def activate
        require_relative 'core_ext/kernel_require'
        @entrypoint.activate
      end

      def eval(path)
        @entrypoint.eval(path)
      end
    end
  end
end

module Ruar
  include Ruar::Setup
end
