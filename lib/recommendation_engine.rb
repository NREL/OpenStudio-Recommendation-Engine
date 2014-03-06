require 'parallel'
begin
  require 'openstudio'
rescue
  $does_not_work = true
end


require 'recommendation-engine/recommendation-engine'
require 'recommendation-engine/version'

