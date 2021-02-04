# frozen_string_literal: true

module Ruar
  class Access
    def initialize(archive)
      # validate!(archive)
      @archive = archive
      # @index = rebuild_index
    end

    def header
      Ruar::Access::Native.header(@archive)
    end

    def index
      Ruar::Access::Native.index(@archive)
    end

    private

    def validate!
      # TODO: validate the archive file
    end

    def validate
      # TODO: validate the archive file
    end
  end
end
