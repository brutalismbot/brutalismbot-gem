module Brutalismbot
  module Reddit
    module Stub
      def stub
        created_utc  = Time.now.utc - rand(86400) - 86400
        post_id      = SecureRandom.alphanumeric(6).downcase
        permalink_id = SecureRandom.alphanumeric.downcase
        image_id     = SecureRandom.alphanumeric
        new(
          kind: "t3",
          data: {
            id:          post_id,
            created_utc: created_utc.to_i,
            permalink:   "/r/brutalism/comments/#{permalink_id}/test/",
            title:       "Post to /r/brutalism",
            preview: {
              images: [
                {
                  source: {
                    url: "https://preview.redd.it/#{image_id}.jpg",
                  }
                }
              ]
            }
          }
        )
      end
    end
  end
end
