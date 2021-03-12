require "json"
require "logger"

module Brutalismbot
  module Logging
    def logger
      @logger ||= Logger.new($stderr, formatter: -> (*_, msg) { "#{ msg }\n" })
    end

    def logger=(logger)
      @logger = logger
    end
  end

  extend Logging
end
