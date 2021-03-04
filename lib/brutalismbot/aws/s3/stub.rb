require "securerandom"

require "brutalismbot/aws/s3/bucket"
require "brutalismbot/slack/stub"
require "brutalismbot/reddit/stub"

module Brutalismbot
  module Aws
    module S3
      module Stubbable
        def stub(stubs = nil)
          stubs ||= 4.times.map { Slack::Auth.stub } + 16.times.map { Reddit::Post.stub }

          contents = stubs.map(&:to_s3).map { |item| [ item[:key], item ] }.to_h

          client = Aws::S3::Client.new(stub_responses: true)

          client.stub_responses :list_objects_v2, -> (context) do
            { contents: contents.values.map { |x| x.slice(:key) } }
          end

          client.stub_responses :get_object, -> (context) do
            contents.fetch(context.params[:key]).slice(:body).map do |k,v|
              [ k, StringIO.new(v) ]
            end.to_h
          rescue
            raise Aws::S3::Errors::NoSuchKey.new nil, "The specified key does not exist."
          end

          client.stub_responses :delete_object, -> (context) do
            { version_id: context.params[:key] }
          end

          new(client: client)
        end
      end

      Bucket.extend(Stubbable)
    end
  end
end
