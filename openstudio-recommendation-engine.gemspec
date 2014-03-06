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

  s.add_runtime_dependency("parallel")
  s.add_runtime_dependency("active_support")

  s.required_ruby_version = '>= 1.8.7'
  
  s.files = Dir.glob("lib/**/*")
  s.require_path = "lib"

end




