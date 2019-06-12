require "brutalismbot/event"
require "brutalismbot/r"
require "brutalismbot/s3"
require "brutalismbot/version"
require "logger"
require "net/https"

module Brutalismbot
  class << self
    @@config = {}

    def config
      @@config
    end

    def config=(config)
      @@config = config
    end

    def logger
      config[:logger]
    end
  end

  class Error < StandardError
  end

  class Auth < Hash
    def channel_id
      dig "incoming_webhook", "channel_id"
    end

    def post(body:, dryrun:nil)
      uri = URI.parse webhook_url
      ssl = uri.scheme == "https"
      Net::HTTP.start(uri.host, uri.port, use_ssl: ssl) do |http|
        if dryrun
          Brutalismbot.logger&.info "POST DRYRUN #{uri}"
        else
          Brutalismbot.logger&.info "POST #{uri}"
          req = Net::HTTP::Post.new uri, "content-type" => "application/json"
          req.body = body
          http.request req
        end
      end
    end

    def team_id
      dig "team_id"
    end

    def webhook_url
      dig "incoming_webhook", "url"
    end
  end

  class Post < Hash
    def created_after(time:)
      created_utc.to_i > time.to_i
    end

    def created_utc
      Time.at(dig("data", "created_utc").to_i).utc
    end

    def permalink
      dig "data", "permalink"
    end

    def title
      dig "data", "title"
    end

    def to_slack
      {
        blocks: [
          {
            type: "image",
            title: {
              type: "plain_text",
              text: "/r/brutalism",
              emoji: true,
            },
            image_url: url,
            alt_text: title,
          },
          {
            type: "context",
            elements: [
              {
                type: "mrkdwn",
                text: "<https://reddit.com#{permalink}|#{title}>",
              },
            ],
          },
        ],
      }
    end

    def url
      images = dig "data", "preview", "images"
      source = images.map{|x| x["source"] }.compact.max do |a,b|
        a.slice("width", "height").values <=> b.slice("width", "height").values
      end
      CGI.unescapeHTML source.dig("url")
    rescue NoMethodError
      dig("data", "media_metadata")&.values&.first&.dig("s", "u")
    end
  end
end
