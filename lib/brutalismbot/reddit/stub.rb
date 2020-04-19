require "securerandom"

module Brutalismbot
  module Reddit
    class Post
      class << self
        def stub(created_utc:nil, post_id:nil, permalink_id:nil, image_id:nil)
          created_utc  ||= Time.now.utc - rand(86400) - 86400
          post_id      ||= SecureRandom.alphanumeric(6).downcase
          permalink_id ||= SecureRandom.alphanumeric.downcase
          image_id     ||= SecureRandom.alphanumeric
          new(
            kind: "t3",
            data: {
              id:          post_id,
              created_utc: created_utc.to_i,
              permalink:   "/r/brutalism/comments/#{permalink_id}/test/",
              title:       "Post to /r/brutalism",
              url:         "https://image.host/#{image_id}.jpg",
              preview: {
                images: [
                  {
                    source: {
                      url: "https://image.host/#{image_id}.jpg",
                      width: 1000,
                      height: 1000,
                    },
                  },
                  {
                    source: {
                      url: "https://image.host/#{image_id}_small.jpg",
                      width: 500,
                      height: 500,
                    }
                  }
                ],
              },
            },
          )
        end
      end
    end
  end
end
