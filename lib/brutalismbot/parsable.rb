require "json"

module Brutalismbot
  module Parsable
    def parse(source, opts = {})
      new(::JSON.parse(source, opts))
    end
  end
end
