lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require "openstudio/recommendation_engine/version"

Gem::Specification.new do |s|
  s.name = "openstudio-recommendation-engine"
  s.version = OpenStudio::RecommendationEngine::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["Nicholas Long","Andrew Parker"]
  s.email = "Nicholas.Long@nrel.gov"
  s.homepage = 'http://openstudio.nrel.gov'
  s.summary = "OpenStudio Recommendation EngineL"
  s.description = "This gem contains the framework needed to execute the recommendation engine on measures that have defined their recommendations."
  s.license = "LGPL"

  s.add_runtime_dependency("rake", "~> 10.1.1")
  s.add_runtime_dependency("colored")
  s.add_runtime_dependency("parallel", "~> 1.19.0")
  s.add_runtime_dependency("json_pure")

  s.add_development_dependency("rspec", "~> 2.12")
  s.add_development_dependency("ci_reporter", "~> 1.9.0")

  s.required_ruby_version = '>= 1.8.7'
  
  s.files = Dir.glob("lib/**/*")
  s.require_path = "lib"

end




