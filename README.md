<img alt="brutalismbot" src="https://brutalismbot.com/banner.png"/>

[![Gem Version](https://badge.fury.io/rb/brutalismbot.svg)](http://badge.fury.io/rb/brutalismbot)
[![Build Status](https://travis-ci.com/brutalismbot/gem.svg)](https://travis-ci.com/brutalismbot/gem)
[![codecov](https://codecov.io/gh/brutalismbot/gem/branch/master/graph/badge.svg)](https://codecov.io/gh/brutalismbot/gem)

Brutalismbot RubyGem

## Installation

```ruby
gem install brutalismbot
```

## Usage

```ruby
require "aws-sdk-s3"
require "brutalismbot"

bucket  = Aws::S3::Bucket.new name: "my-bucket"
brutbot = Brutalismbot::S3::Client.new bucket: bucket, prefix: "my/prefix/"

# Get latest cached post
brutbot.posts.latest

# Get latest post as S3 Object
brutbot.posts.max_key

# Get post-time of latest cached post
limit = brutbot.posts.max_time

# Get newest post after a given time
brutbot.subreddit.posts(:new).since(time: limit).first

# Get current top post
brutbot.subreddit.posts(:top).first
```

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/brutalismbot/gem).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

### See Also

- [Brutalismbot API](https://github.com/brutalismbot/api)
- [Brutalismbot App](https://github.com/brutalismbot/brutalismbot)
- [Brutalismbot Monitoring](https://github.com/brutalismbot/monitoring)
