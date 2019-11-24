require "simplecov"
SimpleCov.start

require "bundler/setup"
require "webmock/rspec"
require "brutalismbot"
require "brutalismbot/stub"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Turn off logging
  Brutalismbot.logger = Logger.new File::NULL

  # Stub AWS responses
  Aws.config.update stub_responses: true
end
