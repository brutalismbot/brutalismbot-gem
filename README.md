<img alt="brutalismbot" src="https://brutalismbot.com/banner.png"/>

[![Build Status](https://travis-ci.com/brutalismbot/gem.svg)](https://travis-ci.com/brutalismbot/gem)
[![Gem Version](https://badge.fury.io/rb/brutalismbot.svg)](http://badge.fury.io/rb/brutalismbot)
[![Test Coverage](https://api.codeclimate.com/v1/badges/83275cbdbf10f9fd2df7/test_coverage)](https://codeclimate.com/github/brutalismbot/gem/test_coverage)
[![Maintainability](https://api.codeclimate.com/v1/badges/83275cbdbf10f9fd2df7/maintainability)](https://codeclimate.com/github/brutalismbot/gem/maintainability)

Brutalismbot RubyGem

## Installation

```ruby
gem install brutalismbot
```

## Usage

```ruby
require "brutalismbot/s3"

brutbot = Brutalismbot::S3::Client.new bucket: "my-bucket", prefix: "my/prefix/"

# Get latest cached post
post = brutbot.posts.last

# Get newest posts
brutbot.subreddit.posts(:new).all

# Get new posts since latest
brutbot.subreddit.posts(:new, before: post.fullname).all

# Get current top post
brutbot.subreddit.posts(:top, limit: 1).first

# Pull latest posts
brutbot.posts.pull

# Mirror a post to all clients
brutbot.auths.mirror post
```

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/brutalismbot/gem).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

### See Also

- [Brutalismbot API](https://github.com/brutalismbot/api)
- [Brutalismbot App](https://github.com/brutalismbot/brutalismbot)
- [Brutalismbot Monitoring](https://github.com/brutalismbot/monitoring)
