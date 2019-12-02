require "brutalismbot/reddit/post"

module Brutalismbot
  module Posts
    class Client
      class << self
        def stub(&block)
          client = new(prefix: "data/test/posts/")
          client.instance_variable_set(:@stubbed, true)

          block = -> { [Reddit::Post.stub] } unless block_given?
          items = block.call.map{|x| [client.key_for(x), x.to_h] }.to_h

          client.client.stub_responses :list_objects_v2, -> (context) do
            keys = items.keys.select{|x| x.start_with? context.params[:prefix] }
            {contents: keys.map{|x| {key:x} }}
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
