require "brutalismbot/reddit/post"

module Brutalismbot
  module Posts
    class Client
      class << self
        def stub(count = nil)
          client = new(prefix: "data/test/posts/")
          client.instance_variable_set(:@stubbed, true)

          items = (count || 1).times.map do
            item = Reddit::Post.stub
            [client.key_for(item), item.to_h]
          end.to_h

          client.client.stub_responses :list_objects, -> (context) do
            {contents: items.keys.map{|x| {key:x} }}
          end

          client.client.stub_responses :get_object, -> (context) do
            {body: StringIO.new(items.fetch(context.params[:key]).to_json)}
          end

          client
        end
      end
    end
  end
end
