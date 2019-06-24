module Brutalismbot
  class Auth < Hash
    def channel_id
      dig "incoming_webhook", "channel_id"
    end

    def post(body:, dryrun:nil)
      uri = URI.parse webhook_url
      ssl = uri.scheme == "https"
      Net::HTTP.start(uri.host, uri.port, use_ssl: ssl) do |http|
        if dryrun
          Brutalismbot.logger.info "POST DRYRUN #{uri}"
        else
          Brutalismbot.logger.info "POST #{uri}"
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
end
