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
              media_metadata: {
                abcdef: {
                  s: {
                    u: "https://preview.image.host/#{image_id}_1.jpg",
                  },
                  p: [
                    {x: 1, y: 1, u: "https://preview.image.host/#{image_id}_1.jpg"},
                    {x: 2, y: 2, u: "https://preview.image.host/#{image_id}_2.jpg"},
                    {x: 3, y: 3, u: "https://preview.image.host/#{image_id}_3.jpg"},
                  ],
                },
                ghijkl: {
                  s: {
                    u: "https://preview.image.host/#{image_id}_2.jpg",
                  },
                  p: [
                    {x: 1, y: 1, u: "https://preview.image.host/#{image_id}_1.jpg"},
                    {x: 2, y: 2, u: "https://preview.image.host/#{image_id}_2.jpg"},
                    {x: 3, y: 3, u: "https://preview.image.host/#{image_id}_3.jpg"},
                  ],
                },
              },
              preview: {
                images: [
                  {
                    source: {
                      url: "https://preview.image.host/#{image_id}_large.jpg",
                      width: 1000,
                      height: 1000,
                    },
                  },
                ],
              },
            },
          )
        end
      end
    end
  end
end
