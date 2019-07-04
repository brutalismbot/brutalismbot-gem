module Brutalismbot
  class Post < Hash
    def created_after?(time)
      created_utc.to_i > time.to_i
    end

    def created_utc
      Time.at(dig("data", "created_utc").to_i).utc
    end

    def fullname
      "#{kind}_#{id}"
    end

    def id
      dig "data", "id"
    end

    def kind
      dig "kind"
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

    class << self
      def stub
        created_utc = Time.now.utc - rand(86400) - 86400
        Post[{
          "data" => {
            "created_utc" => created_utc.to_i,
            "permalink"   => "/r/brutalism/comments/#{SecureRandom.alphanumeric}/test/",
            "title"       => "Post to /r/brutalism",
            "preview" => {
              "images" => [
                {
                  "source" => {
                    "url" => "https://preview.redd.it/#{SecureRandom.alphanumeric}.jpg",
                  }
                }
              ]
            }
          }
        }]
      end
    end
  end
end
