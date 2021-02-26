# frozen_string_literal: true

module Ruar
  class EntryPoint
    def initialize(archive: nil, entry: nil)
      @archive = archive
      @entry = entry
    end

    def activate
      @access = Ruar::Access.new(@archive)
      # First eval this file if option[:entry] is set
      @access.eval(@entry) unless @entry.nil?
    end

    def eval(path, eval_bind = TOPLEVEL_BINDING)
      @access.eval(path, eval_bind)
    end

    def read(path)
      @access.read(path)
    end
  end
end
