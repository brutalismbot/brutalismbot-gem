
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
  spec.files         = Dir["README*", "LICENSE*", "lib/**/*", "Rakefile"]

  spec.add_development_dependency "aws-sdk-s3", "~> 1.0"
  spec.add_development_dependency "codecov",    "~> 0.1"
  spec.add_development_dependency "bundler",    "~> 2.0"
  spec.add_development_dependency "pry",        "~> 0.12"
  spec.add_development_dependency "rake",       "~> 10.0"
  spec.add_development_dependency "rspec",      "~> 3.0"
  spec.add_development_dependency "simplecov",  "~> 0.16"
end
