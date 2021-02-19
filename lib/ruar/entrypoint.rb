# frozen_string_literal: true

module Ruar
  class EntryPoint
    def initialize(option = { archive: nil, entry: nil })
      @archive = option[:archive]
      @entry = option[:entry]
    end

    def activate
      @access = Ruar::Access.new(@archive)
      # First eval this file if option[:entry] is setted
      @access.eval(@entry) unless @entry.nil?
    end

    def eval(path)
      @access.eval(path)
    end
  end
end
