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
        
        init
      end

      def init
        measure_checks = Dir.glob("#{@path_to_measures}/**/recommendation.rb")
       
        applicable_measures = []
          
        measure_checks.each do |measure|
          require "#{File.expand_path(measure)}"

          measure_class_name = File.basename(File.expand_path("../..",measure))
          puts "measure class name is: #{measure_class_name}"

          measure = Object.const_get(measure_class_name).new
          
          if @model
            result = measure.check_applicability(@model)
            if result
              applicable_measures << result
            else
              puts "measure #{measure_class_name} not applicable"
            end
          else
            raise "No model passed into the recommendation engine"
          end
          
        end

        applicable_measures_json = JSON.pretty_generate(applicable_measures)
        puts applicable_measures_json
        return applicable_measures_json

      end

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
