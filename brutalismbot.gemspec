lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "brutalismbot/version"

Gem::Specification.new do |spec|
  spec.name          = "brutalismbot"
  spec.version       = Brutalismbot::VERSION
  spec.authors       = ["Alexander Mancevice"]
  spec.email         = ["smallweirdnum@gmail.com"]
  spec.summary       = %q{Mirror posts from /r/brutalism to Slack}
  spec.description   = %q{A Slack app that mirrors posts from /r/brutalism to a #channel of your choosing using incoming webhooks.}
  spec.homepage      = "https://brutalismbot.com"
  spec.license       = "MIT"
  spec.require_paths = ["lib"]
  spec.files         = Dir["README*", "LICENSE*", "lib/**/*"]

  spec.add_dependency "twitter", "~> 7.0"
end
