require "json"

require "brutalismbot"

module Brutalismbot
  module Aws
    module Lambda
      def handler(name, &block)
        define_method(name) do |event:nil, context:nil|
          original_logger = Brutalismbot.logger
          Brutalismbot.logger = Logger.new(context)
          Brutalismbot.logger.info("EVENT #{ event.to_json }")
          result = yield(event, context) if block_given?
          Brutalismbot.logger.info("RETURN #{ result.to_json }")
          Brutalismbot.logger = original_logger
          result
        end
      end

      class Logger < Logger
        def initialize(context = nil)
          super($stdout)
          self.formatter = -> (severity, time, progname, msg) { "#{ severity } #{ progname } #{ msg }\n" }
          self.progname  = begin
            "RequestId: #{ context.aws_request_id }"
          rescue NoMethodError
            "-"
          end
        end
      end
    end
  end
end

extend Brutalismbot::Aws::Lambda
