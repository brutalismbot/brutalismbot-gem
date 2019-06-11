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
brutbot = Brutalismbot::S3::Client.new bucket: bucket,
                                       prefix: "my/prefix/"

# Get new posts after a given time
brutbot.subreddit.new_posts.after Time.parse("2019-06-01 12:00:00Z")

# Get current top post
brutbot.subreddit.top_post

# Get latest cached post
brutbot.posts.latest

# Get max key in posts
brutbot.posts.max_key
```

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/brutalismbot/gem).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

### See Also

- [Brutalismbot API](https://github.com/brutalismbot/api)
- [Brutalismbot App](https://github.com/brutalismbot/brutalismbot)
- [Brutalismbot Monitoring](https://github.com/brutalismbot/monitoring)
