require "bundler"    #don't use bundler right now because it runs these rake tasks differently
Bundler.setup

require "rake"
require "rspec/core/rake_task"

$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "openstudio/recommendation_engine/recommendation_engine"
require "openstudio/recommendation_engine/version"

task :gem => :build
desc "build gem"
task :build do
  system "gem build openstudio-recommendation-engine.gemspec"
end

desc "install gem from local build"
task :install => :build do
  system "gem install openstudio-recommendation-engine-#{OpenStudio::RecommendationEngine::VERSION}.gem --no-ri --no-rdoc"
end

desc "build and release version of gem on rubygems.org"
task :release => :build do
  system "git tag -a v#{OpenStudio::RecommendationEngine::VERSION} -m 'Tagging #{OpenStudio::RecommendationEngine::VERSION}'"
  system "git push --tags"
  system "gem push openstudio-recommendation-engine-#{OpenStudio::RecommendationEngine::VERSION}.gem"
  system "rm openstudio-recommendation-engine-#{OpenStudio::RecommendationEngine::VERSION}.gem"
end

desc "uninstall all gems"
task :uninstall do
  system "gem uninstall openstudio-recommendation-engine -a"
end

task :reinstall => [:uninstall, :install]

RSpec::Core::RakeTask.new("spec") do |spec|
  puts "running tests..."
  spec.rspec_opts = %w(--format progress --format CI::Reporter::RSpec)
  spec.pattern = "spec/**/*_spec.rb"
end

desc "Default task run rspec tests"
task :test => :spec
task :default => :spec

