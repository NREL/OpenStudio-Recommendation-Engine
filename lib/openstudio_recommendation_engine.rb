require 'rubygems'   # for 1.8.7
                    
begin
  require 'openstudio'
  $openstudio_loaded = true
rescue
  $openstudio_loaded = false
end

require 'parallel'
require 'openstudio/recommendation_engine/recommendation_engine'
require 'openstudio/recommendation_engine/version'
require 'openstudio/helpers/safe_load'
require 'json/pure'


