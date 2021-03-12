require "brutalismbot/base/storage_collection"
require "brutalismbot/reddit/post"

module Brutalismbot
  module Reddit
    class PostCollection < Base::StorageCollection
      def list(name:nil, limit:nil)
        @storage.list_reddit_posts(name:name, limit:limit)
      end

      def max_created_utc
        binding.pry
      end

      def put(*posts)
        @storage.put_reddit_posts(*posts) { |post| { name: post.name } }
      end
    end
  end
end
