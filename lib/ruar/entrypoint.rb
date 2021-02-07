# frozen_string_literal: true

module Ruar
  module EntryPoint
    def self.setup(option = { archive: nil, entry: nil })
      @@archive = option[:archive]
      @@entry = option[:entry]
      self
    end

    def self.activate
      @@access = Ruar::Access.new(@@archive)
      @@access.eval(@@entry) unless @@entry.nil?
      self
    end

    def self.require(path)
      @@access.eval(path)
    end
  end
end
