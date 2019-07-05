module Brutalismbot
  class Auth < Hash
    def channel_id
      dig "incoming_webhook", "channel_id"
    end

    def post(body:, dryrun:nil)
      uri = URI.parse webhook_url
      ssl = uri.scheme == "https"
      req = Net::HTTP::Post.new uri, "content-type" => "application/json"
      req.body = body
      Brutalismbot.logger.info "POST #{dryrun ? "DRYRUN " : ""}#{uri}"
      if dryrun
        Net::HTTPOK.new "1.1", "204", "ok"
      else
        Net::HTTP.start(uri.host, uri.port, use_ssl: ssl) do |http|
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

    class << self
      def stub
        bot_id     = "B#{SecureRandom.alphanumeric(8).upcase}"
        channel_id = "C#{SecureRandom.alphanumeric(8).upcase}"
        team_id    = "T#{SecureRandom.alphanumeric(8).upcase}"
        user_id    = "U#{SecureRandom.alphanumeric(8).upcase}"
        Auth[{
          "ok"           => true,
          "access_token" => "<token>",
          "scope"        => "identify,incoming-webhook",
          "user_id"      => user_id,
          "team_name"    => "My Team",
          "team_id"      => team_id,
          "incoming_webhook" => {
            "channel"           => "#brutalism",
            "channel_id"        => channel_id,
            "configuration_url" => "https://my-team.slack.com/services/#{bot_id}",
            "url"               => "https://hooks.slack.com/services/#{team_id}/#{bot_id}/1234567890abcdef12345678",
          },
          "scopes" => [
            "identify",
            "incoming-webhook",
          ],
        }]
      end
    end
  end
end
