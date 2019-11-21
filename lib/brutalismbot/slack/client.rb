require "aws-sdk-s3"

require "brutalismbot/logger"
require "brutalismbot/s3"
require "brutalismbot/slack/auth"

module Brutalismbot
  module Slack
    class Client < S3::Client
      def initialize(bucket:nil, prefix:nil, client:nil)
        bucket ||= ENV["SLACK_S3_BUCKET"] || "brutalismbot"
        prefix ||= ENV["SLACK_S3_PREFIX"] || "data/v1/auths/"
        super
      end

      def install(auth, dryrun:nil)
        key = key_for(auth)
        Brutalismbot.logger.info("PUT #{"DRYRUN " if dryrun}s3://#{@bucket}/#{key}")
        bucket.put_object(key: key, body: auth.to_json) unless dryrun
      end

      def key_for(auth)
        File.join(
          @prefix,
          "team=#{auth.team_id}",
          "channel=#{auth.channel_id}",
          "oauth.json",
        )
      end

      def list(options = {})
        options = {bucket: @bucket, prefix: @prefix, client: @client}.merge(options)
        S3::Prefix.new(options) do |object|
          Brutalismbot.logger.info("GET s3://#{@bucket}/#{object.key}")
          Auth.parse(object.get.body.read)
        end
      end

      def push(post, dryrun:nil)
        list.each do |auth|
          key = key_for(auth)
          Brutalismbot.logger.info("PUSH #{"DRYRUN " if dryrun}s3://#{@bucket}/#{key}")
          auth.post(post, dryrun: dryrun)
        end
      end

      def uninstall(auth, dryrun:nil)
        key = key_for(auth)
        Brutalismbot.logger.info("DELETE #{"DRYRUN " if dryrun}s3://#{@bucket}/#{key}")
        bucket.delete_objects(delete: {objects: [{key: key}]}) unless dryrun
      end
    end
  end
end
