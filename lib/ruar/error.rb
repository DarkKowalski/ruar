# frozen_string_literal: true

module Ruar
  module Error
    class BaseError < RuntimeError
    end

    class FileNotFound < BaseError
      attr_reader :path

      def initialize(path)
        @path = path
        super(+"file does not exist in ruar -- #{path}")
      end
    end
  end
end
