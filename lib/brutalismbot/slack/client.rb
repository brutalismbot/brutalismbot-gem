require "aws-sdk-s3"

require "brutalismbot/logger"
require "brutalismbot/s3/client"
require "brutalismbot/s3/prefix"
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
        @client.put_object(bucket: @bucket, key: key, body: auth.to_json) unless dryrun
      end

      def key_for(auth)
        File.join(@prefix, auth.path)
      end

      def get(**options)
        super {|object| Auth.parse(object.body.read) }
      end

      def list(**options)
        super(**options) do |object|
          Brutalismbot.logger.info("GET s3://#{@bucket}/#{object.key}")
          Auth.parse(object.get.body.read)
        end
      end

      def push(post, dryrun:nil)
        list.map do |auth|
          key = key_for(auth)
          Brutalismbot.logger.info("PUSH #{"DRYRUN " if dryrun}s3://#{@bucket}/#{key}")
          auth.push(post, dryrun: dryrun)
        end
      end

      def uninstall(auth, dryrun:nil)
        prefix = File.join(@prefix, "team=#{auth.team_id}/")
        Brutalismbot.logger.info("LIST s3://#{@bucket}/#{prefix}*")
        bucket.objects(prefix: prefix).map do |object|
          Brutalismbot.logger.info("DELETE #{"DRYRUN " if dryrun}s3://#{@bucket}/#{object.key}")
          object.delete unless dryrun
        end
      end
    end
  end
end
