require "rake/clean"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

namespace :gem do
  require "bundler/gem_tasks"

  desc "Publish gem on RubyGems"
  task :push => :build do |t,args|
    sh "gem", "push", "pkg/brutalismbot-#{Brutalismbot::VERSION}.gem"
  end
end
