require "brutalismbot/event"
require "brutalismbot/oauth"
require "brutalismbot/r"
require "brutalismbot/s3"
require "brutalismbot/version"
require "logger"
require "net/https"

module Brutalismbot
  class << self
    attr_accessor :config

    def logger
      config[:logger]
    end
  end

  self.config = {}

  class Error < StandardError
  end
end
