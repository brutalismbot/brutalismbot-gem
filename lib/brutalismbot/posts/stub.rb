require "aws-sdk-s3"

require "brutalismbot/reddit/post"

module Brutalismbot
  module Posts
    class Client
      def stub!(items = nil)
        items ||= [Reddit::Post.stub]
        items   = items.map{|x| [key_for(x), x.to_h] }.to_h

        @client = Aws::S3::Client.new(stub_responses: true)

        @client.stub_responses :list_objects_v2, -> (context) do
          keys = items.keys.select{|x| x.start_with? context.params[:prefix] }
          {contents: keys.map{|x| {key:x} }}
        end

        @client.stub_responses :get_object, -> (context) do
          {body: StringIO.new(items.fetch(context.params[:key]).to_json)}
        end

        @stubbed = true

        self
      end

      class << self
        def stub(items = nil)
          new(prefix: "data/test/posts/").stub!(items)
        end
      end
    end
  end
end
