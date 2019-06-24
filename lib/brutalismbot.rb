require "brutalismbot/auth"
require "brutalismbot/post"
require "brutalismbot/r"
require "brutalismbot/s3"
require "brutalismbot/version"
require "logger"
require "net/https"

module Brutalismbot
  class << self
    @@config = {}
    @@logger = Logger.new File::NULL

    def config
      @@config
    end

    def config=(config)
      @@config = config || {}
    end

    def logger
      config[:logger] || @@logger
    end

    def logger=(logger)
      config[:logger] = logger
    end
  end

  class Error < StandardError
  end
end
