require "logger"

module Brutalismbot
  module Logger
    def logger
      @logger ||= ::Logger.new($stderr, formatter: -> (*x) { "#{x.last}\n" })
    end

    def logger=(logger)
      @logger = logger
    end
  end

  extend Logger
end
