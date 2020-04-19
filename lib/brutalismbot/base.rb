require "forwardable"
require "json"

module Brutalismbot
  module Parser
    def parse(source, opts = {})
      item = JSON.parse(source, opts)
      new(**item)
    end
  end

  class Base
    extend Forwardable
    extend Parser

    def_delegators :@item, :[], :dig, :fetch, :to_h, :to_json

    def initialize(**item)
      @item = JSON.parse(item.to_json)
    end
  end
end
