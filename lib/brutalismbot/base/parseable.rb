module Brutalismbot
  module Base
    module Parseable
      def parse(source, opts = {})
        new(**JSON.parse(source, opts))
      end
    end
  end
end
