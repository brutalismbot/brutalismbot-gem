require "json"
require "net/http"

require "brutalismbot/base/item"
require "brutalismbot/logging"
require "brutalismbot/slack/response"

module Brutalismbot
  module Slack
    class Webhook < Base::Item
      def inspect
        "#<#{ self.class } team_id: #{ team_id }, channel_id: #{ channel_id }>"
      end

      def key
        "#{ team_id }/#{ channel_id }"
      end

      def channel_id
        @data.dig("incoming_webhook", "channel_id")
      end

      def channel_name
        @data.dig("incoming_webhook", "channel")
      end

      def team_id
        @data["team_id"] || @data.dig("team", "id")
      end

      def team_name
        @data["team_name"] || @data.dig("team", "name")
      end

      def url
        URI.parse(@data.dig("incoming_webhook", "url"))
      end
    end
  end
end
