<img alt="brutalismbot" src="https://brutalismbot.com/banner.png"/>

![gem](https://img.shields.io/gem/v/brutalismbot?logo=rubygems&logoColor=eee&style=flat-square)
[![rspec](https://img.shields.io/github/workflow/status/brutalismbot/gem/rspec?logo=github&style=flat-square)](https://github.com/brutalismbot/gem/actions)
[![coverage](https://img.shields.io/codeclimate/coverage/brutalismbot/gem?logo=code-climate&style=flat-square)](https://codeclimate.com/github/brutalismbot/gem/test_coverage)
[![maintainability](https://img.shields.io/codeclimate/maintainability/brutalismbot/gem?logo=code-climate&style=flat-square)](https://codeclimate.com/github/brutalismbot/gem/maintainability)

Brutalismbot RubyGem

## Installation

```ruby
gem install brutalismbot
```

## Usage

```ruby
require "brutalismbot"

bot = Brutalismbot::Client.new

# Get latest cached post
post = bot.posts.last

# Get newest posts
bot.reddit.list(:new).all

# Get new posts since latest
bot.reddit.list(:new, before: post.fullname).all

# Get current top post
bot.reddit.list(:top, limit: 1).first

# Pull latest posts
bot.pull

# Mirror a post to all clients
bot.push post
```

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/brutalismbot/gem).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

### See Also

- [Brutalismbot API](https://github.com/brutalismbot/api)
- [Brutalismbot App](https://github.com/brutalismbot/brutalismbot)
- [Brutalismbot Monitoring](https://github.com/brutalismbot/monitoring)
