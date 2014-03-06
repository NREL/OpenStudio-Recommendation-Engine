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

#load a model into OS & version translates, exiting and erroring if a problem is found
module OpenStudio
  def safe_load_model(model_path_string)
    model_path = OpenStudio::Path.new(model_path_string)
    if OpenStudio::exists(model_path)
      versionTranslator = OpenStudio::OSVersion::VersionTranslator.new
      model = versionTranslator.loadModel(model_path)
      if model.empty?
        puts "Version translation failed for #{model_path_string}"
        exit
      else
        model = model.get
      end
    else
      raise "#{model_path_string} couldn't be found"
    end
    return model
  end
  module_function :safe_load_model
end
