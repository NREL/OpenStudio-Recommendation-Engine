######################################################################
#  Copyright (c) 2008-2013, Alliance for Sustainable Energy.
#  All rights reserved.
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation; either
#  version 2.1 of the License, or (at your option) any later version.
#  
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Lesser General Public License for more details.
#  
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
#####################################################################

module OpenStudio
  module RecommendationEngine
    class RecommendationEngine
      def initialize(model, path_to_measures)
        @model = model
        @path_to_measures = path_to_measures
      end

      def check_measures
        measure_checks = Dir.glob("#{@path_to_measures}/**/recommendation.rb")
        
        applicable_measures = []
        debug_outputs = []
          
        measure_checks.each do |measure|
          require "#{File.expand_path(measure)}"

          measure_class_name = File.basename(File.expand_path("../..",measure))
          puts "checking #{measure_class_name}"

          measure = Object.const_get(measure_class_name).new
          
          if @model
            results_hash, debug_hash = measure.check_applicability(@model)
            if results_hash
              applicable_measures << results_hash
            else
              puts "measure #{measure_class_name} not applicable"
            end
            debug_outputs << debug_hash
          else
            raise "No model passed into the recommendation engine"
          end
          
        end
        
        return [applicable_measures,debug_outputs]

      end

      # measures_hash looks like
      # {
        # "measure": {
          # "uid": "123-fake-daylight-uid",
          # "name": "AddEconomizer",
          # "spaces": [
            # "427_office_1_North Perimeter Space",
            # "427_office_1_South Perimeter Space",
            # "427_office_1_West Perimeter Space",
            # "427_office_1_East Perimeter Space"
          # ]
          # "arguments": {
            # "cost_per_thing":50,
            # "input_2":true,
          # }
        # },
        # "measure": {
          # "uid": "123-fake-daylight-uid",
          # "name": "AddDaylightControls",
          # "spaces": [
            # "427_office_1_North Perimeter Space",
            # "427_office_1_South Perimeter Space",
            # "427_office_1_West Perimeter Space",
            # "427_office_1_East Perimeter Space"
          # ]
        # }
      # }

      def apply_measures(model, measures_hash)
      
        messages = {}
            
        #loop through each measure in the measures_hash
        measures_hash.each do |m|
          puts JSON.pretty_generate(m)
          measure_name = m['measure']['name']
          puts measure_name
          messages[measure_name] = []
          puts File.expand_path(measure_name)
          require "#{@path_to_measures}/#{measure_name}/measure"
          

          #make os argument vector and assign values from measures_json
          measure = Object.const_get(measure_name).new
          
          arguments = measure.arguments(model)
          runner = OpenStudio::Ruleset::OSRunner.new
          
          argument_map = OpenStudio::Ruleset::OSArgumentMap.new
          arguments.each do |arg|
            argument_map[arg.name] = arg.clone
          end
          
          if m['measure']['arguments']
            m['measure']['arguments'].each do |arg_name, arg_val|
              v = argument_map[arg_name]
              raise "Could not find argument map in measure" if not v
              value_set = v.setValue(arg_val)
              raise "Could not set argument #{arg_name} of value #{arg_val} on model" unless value_set
              argument_map[arg_name] = v.clone  
            end
          end 
          
          #run the measure
          measure.run(model, runner, argument_map)
          
          #log the messages from when running the measure
          result = runner.result
          messages[measure_name] << result.initialCondition.get.logMessage if result.initialCondition.is_initialized
          messages[measure_name] << result.finalCondition.get.logMessage if result.finalCondition.is_initialized
          result.warnings.each { |w| messages[measure_name] << w.logMessage}
          result.errors.each { |w| messages[measure_name] << w.logMessage}
          result.info.each { |w| messages[measure_name] << w.logMessage}
 
        end #next measure
     
        return model,messages
        
      end #apply_measures      
       
    end
  end


end

# Microsoft Windows [Version 6.1.7601]
# Copyright (c) 2009 Microsoft Corporation.  All rights reserved.

# C:\Users\aparker>irb
# irb(main):001:0> require
# ArgumentError: wrong number of arguments (0 for 1)
# from (irb):1:in `require'
# from (irb):1
# irb(main):002:0> ^C
# irb(main):002:0> exit
# Terminate batch job (Y/N)? n

# C:\Users\aparker>gem install parallel
# Fetching: parallel-0.9.2.gem (100%)
# Successfully installed parallel-0.9.2
# 1 gem installed
# Installing ri documentation for parallel-0.9.2...
# Installing RDoc documentation for parallel-0.9.2...

# C:\Users\aparker>irb
# irb(main):001:0> Parallel.each(['a','b','c']){|a| puts a}
# NameError: uninitialized constant Parallel
# from (irb):1
# irb(main):002:0> require 'parallel'
# LoadError: no such file to load -- parallel
# from (irb):2:in `require'
# from (irb):2
# irb(main):003:0> require 'rubygems'
# => true
# irb(main):004:0> require 'parallel'
# => true
# irb(main):005:0> Parallel.each(['a','b','c']){|a| puts a}
# NotImplementedError: fork() function is unimplemented on this machine
# from C:/Ruby187/lib/ruby/gems/1.8/gems/parallel-0.9.2/lib/parallel.rb:291:in `fork'
# from C:/Ruby187/lib/ruby/gems/1.8/gems/parallel-0.9.2/lib/parallel.rb:291:in `worker'
# from C:/Ruby187/lib/ruby/gems/1.8/gems/parallel-0.9.2/lib/parallel.rb:279:in `create_workers'
# from C:/Ruby187/lib/ruby/gems/1.8/gems/parallel-0.9.2/lib/parallel.rb:278:in `each'
# from C:/Ruby187/lib/ruby/gems/1.8/gems/parallel-0.9.2/lib/parallel.rb:278:in `create_workers'
# from C:/Ruby187/lib/ruby/gems/1.8/gems/parallel-0.9.2/lib/parallel.rb:242:in `work_in_processes'
# from C:/Ruby187/lib/ruby/gems/1.8/gems/parallel-0.9.2/lib/parallel.rb:114:in `map'
# from C:/Ruby187/lib/ruby/gems/1.8/gems/parallel-0.9.2/lib/parallel.rb:81:in `each'
# from (irb):5
# irb(main):006:0> Parallel.each(['a','b','c'], :in_threads => 3){|a| puts a}
# abc


# => ["a", "b", "c"]
# irb(main):007:0> Parallel.each(['a','b','c'], :in_threads => 1){|a| puts a}
# a
# b
# c
# => ["a", "b", "c"]
# irb(main):008:0> Parallel.each(['a','b','c'], :in_threads => 2){|a| puts wait 10}
# NoMethodError: undefined method `wait' for main:Object
# from (irb):8
# from C:/Ruby187/lib/ruby/gems/1.8/gems/parallel-0.9.2/lib/parallel.rb:386:in `call'
# from C:/Ruby187/lib/ruby/gems/1.8/gems/parallel-0.9.2/lib/parallel.rb:386:in `call_with_index'
# from C:/Ruby187/lib/ruby/gems/1.8/gems/parallel-0.9.2/lib/parallel.rb:229:in `work_in_threads'
# from C:/Ruby187/lib/ruby/gems/1.8/gems/parallel-0.9.2/lib/parallel.rb:397:in `with_instrumentation'
# from C:/Ruby187/lib/ruby/gems/1.8/gems/parallel-0.9.2/lib/parallel.rb:227:in `work_in_threads'
# from C:/Ruby187/lib/ruby/gems/1.8/gems/parallel-0.9.2/lib/parallel.rb:221:in `loop'
# from C:/Ruby187/lib/ruby/gems/1.8/gems/parallel-0.9.2/lib/parallel.rb:221:in `work_in_threads'
# from C:/Ruby187/lib/ruby/gems/1.8/gems/parallel-0.9.2/lib/parallel.rb:65:in `in_threads'
# from C:/Ruby187/lib/ruby/gems/1.8/gems/parallel-0.9.2/lib/parallel.rb:64:in `initialize'
# from C:/Ruby187/lib/ruby/gems/1.8/gems/parallel-0.9.2/lib/parallel.rb:64:in `new'
# from C:/Ruby187/lib/ruby/gems/1.8/gems/parallel-0.9.2/lib/parallel.rb:64:in `in_threads'
# from C:/Ruby187/lib/ruby/gems/1.8/gems/parallel-0.9.2/lib/parallel.rb:63:in `times'
# from C:/Ruby187/lib/ruby/gems/1.8/gems/parallel-0.9.2/lib/parallel.rb:63:in `in_threads'
# from C:/Ruby187/lib/ruby/gems/1.8/gems/parallel-0.9.2/lib/parallel.rb:219:in `work_in_threads'
# from C:/Ruby187/lib/ruby/gems/1.8/gems/parallel-0.9.2/lib/parallel.rb:112:in `map'
# from C:/Ruby187/lib/ruby/gems/1.8/gems/parallel-0.9.2/lib/parallel.rb:81:in `each'
# from (irb):8
# from ♥:0irb(main):009:0> Parallel.each(['a','b','c'], :in_threads => 2){|Terminate batch job (Y/N)?
# ^C
# C:\Users\aparker>irb
# irb(main):001:0>
