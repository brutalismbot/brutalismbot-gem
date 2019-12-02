require "brutalismbot"
require "brutalismbot/posts/stub"
require "brutalismbot/reddit/stub"
require "brutalismbot/slack/stub"

Aws.config.update(stub_responses: true)

module Brutalismbot
  class Client
    def stub!(posts:nil, slack:nil)
      @posts   = Posts::Client.stub(posts)
      @slack   = Slack::Client.stub(posts)
      @stubbed = true

      self
    end

    class << self
      def stub(posts:nil, slack:nil)
        new.stub!(posts: posts, slack: slack)
      end
    end
  end
end
