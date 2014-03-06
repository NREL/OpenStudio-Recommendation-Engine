#see the URL below for information on how to write OpenStudio measures
# http://openstudio.nrel.gov/openstudio-measure-writing-guide

#see the URL below for information on using life cycle cost objects in OpenStudio
# http://openstudio.nrel.gov/openstudio-life-cycle-examples

#see the URL below for access to C++ documentation on model objects (click on "model" in the main window to view model objects)
# http://openstudio.nrel.gov/sites/openstudio.nrel.gov/files/nv_data/cpp_documentation_it/model/html/namespaces.html

#start the measure
class AddDaylightSensorstoControlLightinginPerimeterZones < OpenStudio::Ruleset::ModelUserScript
  
  #define the name that a user will see, this method may be deprecated as
  #the display name in PAT comes from the name field in measure.xml
  def name
    return "AddDaylightSensorstoControlLightinginPerimeterZones"
  end
  
  #define the arguments that the user will input
  def arguments(model)
    args = OpenStudio::Ruleset::OSArgumentVector.new
        
    return args
  end #end the arguments method

  #define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)
    
    #use the built-in error checking 
    if not runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end

    spaces_with_daylight_potential = 0
    spaces_daylight_sensors_added_to = []
    
    #record the number of spaces that had daylighting control to start
    initial_spaces_with_daylight_sensors = 0
    model.getSpaces.each do |space|
      initial_spaces_with_daylight_sensors += space.daylightingControls.size
    end
         
    #loop through all spaces in the model  
    model.getSpaces.each do |space|
      runner.registerInfo("CHECKING DAYLIGHTING FOR: #{space.name.get}")
      num_ext_windows = 0
      total_daylight_area_m2 = 0
      existing_daylighting_controls = 0
      daylight_windows = {}
      
      
      #find a floor in the space for later use
      floor_surface = nil
      space.surfaces.each do |surface|
        #find a floor in the space for later use in determining window size
        if surface.surfaceType == "Floor"
          floor_surface = surface
          break  
        end
      end
      if not floor_surface
        runner.registerWarning("could not find a floor in the space #{space.name.get}")
        next #next space
      end
      
      #find all exterior windows in the space and calculate their daylighting areas
      space.surfaces.each do |surface|
        if surface.outsideBoundaryCondition == "Outdoors" and surface.surfaceType == "Wall"
          surface.subSurfaces.each do |sub_surface|
            if sub_surface.outsideBoundaryCondition == "Outdoors" and (sub_surface.subSurfaceType == "FixedWindow" or sub_surface.subSurfaceType == "OperableWindow")
              num_ext_windows += 1
              net_area_m2 = sub_surface.netArea
              runner.registerInfo("#{sub_surface.name.get}, area = #{net_area_m2}m^2")
               
              #find the head height and sill height of the window
              vertex_heights_above_floor = []
              sub_surface.vertices.each do |vertex|
                vertex_on_floorplane = floor_surface.plane.project(vertex)
                vertex_heights_above_floor << (vertex - vertex_on_floorplane).length
              end
              sill_height_m = vertex_heights_above_floor.min
              head_height_m = vertex_heights_above_floor.max
              runner.registerInfo("---head height = #{head_height_m}m, sill height = #{sill_height_m}m")
              
              #find the width of the window
              if not sub_surface.vertices.size == 4
                runner.registerWarning("cannot handle windows with #{sub_surface.vertices.size} vertices; skipping window")
                next
              end
              prev_vertex_on_floorplane = nil
              max_window_width_m = 0
              sub_surface.vertices.each do |vertex|
                vertex_on_floorplane = floor_surface.plane.project(vertex)
                if not prev_vertex_on_floorplane
                  prev_vertex_on_floorplane = vertex_on_floorplane
                  next
                end
                width_m = (prev_vertex_on_floorplane - vertex_on_floorplane).length
                if width_m > max_window_width_m
                  max_window_width_m = width_m
                end
              end
              
              #find the width of the wall containing the window
              if not sub_surface.vertices.size == 4
                runner.registerWarning("cannot handle walls with #{sub_surface.vertices.size} vertices; skipping wall")
                next
              end
              prev_vertex_on_floorplane = nil
              max_wall_width_m = 0
              sub_surface.vertices.each do |vertex|
                vertex_on_floorplane = floor_surface.plane.project(vertex)
                if not prev_vertex_on_floorplane
                  prev_vertex_on_floorplane = vertex_on_floorplane
                  next
                end
                width_m = (prev_vertex_on_floorplane - vertex_on_floorplane).length
                if width_m > max_wall_width_m
                  max_wall_width_m = width_m
                end
              end
              
              #if window + 2ft on each side is extends out of the space, don't add it to the daylight area width
              max_width_plus_side_m = nil
              if (max_window_width_m + OpenStudio::convert(4,"ft","m").get) >= max_wall_width_m
                max_width_plus_side_m = max_window_width_m
                runner.registerInfo("---adding 2ft on sides extends daylight area outside space, not adding to daylight area width")                
              else
                max_width_plus_side_m = max_window_width_m + OpenStudio::convert(4,"ft","m").get
                runner.registerInfo("---width plus 2ft on sides = #{max_width_plus_side_m}m")
              end

              #find the daylighting area of the window
              window_daylight_area_m2 = head_height_m * max_width_plus_side_m
              runner.registerInfo("---daylight area = #{window_daylight_area_m2}m^2")
              total_daylight_area_m2 += window_daylight_area_m2
              
              #record the azimuth of the window
              group = sub_surface.planarSurfaceGroup
              if group.is_initialized
                group = group.get
                site_transformation = group.buildingTransformation
                site_vertices = site_transformation * sub_surface.vertices
                site_outward_normal = OpenStudio::getOutwardNormal(site_vertices)
                if site_outward_normal.empty?
                  runner.registerError("could not compute outward normal for #{sub_surface.name.get}")
                  return false
                end
                site_outward_normal = site_outward_normal.get
                north = OpenStudio::Vector3d.new(0.0,1.0,0.0)
                if site_outward_normal.x < 0.0
                  azimuth = 360.0 - OpenStudio::radToDeg(OpenStudio::getAngle(site_outward_normal, north))
                else
                  azimuth = OpenStudio::radToDeg(OpenStudio::getAngle(site_outward_normal, north))
                end
              end
              #TODO will need to modify to work for buildings in the southern hemisphere
              if (azimuth >= 315.0 or azimuth < 45.0)
                facade = "4-North"
              elsif (azimuth >= 45.0 and azimuth < 135.0)
                facade = "3-East"
              elsif (azimuth >= 135.0 and azimuth < 225.0)
                facade = "1-South"
              elsif (azimuth >= 225.0 and azimuth < 315.0)
                facade = "2-West"
              else
                runner.registerError("window #{sub_surface.name.get} appears to face directly upward or downward.")
                return false
              end
              
              #log the window properties to use when creating daylight sensors
              window_properties = {:facade => facade, :daylight_area_m2 => window_daylight_area_m2, :handle => sub_surface.handle, :head_height_m => head_height_m}
              daylight_windows[sub_surface] = window_properties
                        
              #TODO handle overlapping daylighting areas         
                        
            end      
          end #next sub-surface
        end
      end #next surface

      #find existing daylighting controls
      existing_daylighting_controls = space.daylightingControls.size

      #warn if daylight area greater than space floor area
      #this could happen with tall rooms, large windows on all sides, etc
      if total_daylight_area_m2 > space.floorArea
        runner.registerWarning("daylight area > floor area; floor area is 100% daylightable")
        total_daylight_area_m2 = space.floorArea
      end
      
      #convert daylight area to IP
      total_daylight_area_ft2 = OpenStudio::convert(total_daylight_area_m2,"m^2","ft^2").get
      
      #report out a summary of the space
      runner.registerInfo("Daylighting Summary")
      runner.registerInfo("---space has #{num_ext_windows} exterior windows")
      runner.registerInfo("---space has #{existing_daylighting_controls} existing daylighting controls")
      runner.registerInfo("---space has #{total_daylight_area_ft2}ft^2 of daylight area")
      
      #Conditions for daylighting to be applicable
      # 1. Has vertical fenestration
      # 2. Without daylighting controls
      # 3. Daylight Area exceeds 250 sq.ft 
      if num_ext_windows > 0 and total_daylight_area_ft2 > 250.0 and existing_daylighting_controls == 0
        spaces_with_daylight_potential += 1
        runner.registerInfo("---Daylighting: APPLICABLE")
        
        #find the space type and determine the corresponding daylight setpoint
        space_name = space.name.get
        daylight_stpt_lux = nil
        if space_name.match(/post_office/)# Post Office 500 Lux
          daylight_stpt_lux = 500
        elsif space_name.match(/medical_office/)# Medical Office 3000 Lux
          daylight_stpt_lux = 3000
        elsif space_name.match(/office/)# Office 500 Lux
          daylight_stpt_lux = 500
        elsif space_name.match(/school/)# School 500 Lux
          daylight_stpt_lux = 500
        elsif space_name.match(/retail/)# Retail 1000 Lux
          daylight_stpt_lux = 1000
        elsif space_name.match(/warehouse/)# Warehouse 200 Lux
          daylight_stpt_lux = 200
        elsif space_name.match(/hotel/)# Hotel 300 Lux
          daylight_stpt_lux = 300
        elsif space_name.match(/apartment/)# Apartment 200 Lux
          daylight_stpt_lux = 200
        elsif space_name.match(/courthouse/)# Courthouse 300 Lux
          daylight_stpt_lux = 300
        elsif space_name.match(/library/)# Library 500 Lux
          daylight_stpt_lux = 500
        elsif space_name.match(/community_center/)# Community Center 300 Lux
          daylight_stpt_lux = 300
        elsif space_name.match(/senior_center/)# Senior Center 1000 Lux
          daylight_stpt_lux = 1000
        elsif space_name.match(/city_hall/)# City Hall 500 Lux
          daylight_stpt_lux = 500
        else
          runner.registerWarning("Space #{space_name} is an unknown space type, assuming office and 300 Lux daylight setpoint")
          daylight_stpt_lux = 300
        end
        
        #get the zone that the space is in
        zone = space.thermalZone
        if zone.empty?
          runner.registerError("Space #{space.name.get} has no thermal zone")
          return false
        else
          zone = space.thermalZone.get
        end
        
        #add the daylight sensors
        sorted_daylight_windows = daylight_windows.sort_by { |handle, vals| vals[:facade] }
        
        #primary sensor controlled fraction
        pri_daylight_window_info = sorted_daylight_windows[0][1]
        pri_daylight_area = pri_daylight_window_info[:daylight_area_m2]
        pri_ctrl_frac = pri_daylight_area/space.floorArea
        runner.registerInfo("primary daylighting control fraction = #{pri_ctrl_frac}")
        
        #secondary sensor controlled fraction
        sec_daylight_window_info = nil
        sec_ctrl_frac = nil
        if sorted_daylight_windows.size > 1
          sec_daylight_window_info = sorted_daylight_windows[1][1]
          sec_daylight_area = sec_daylight_window_info[:daylight_area_m2]
          sec_ctrl_frac = sec_daylight_area/space.floorArea
          runner.registerInfo("secondary daylighting control fraction = #{sec_ctrl_frac}")
        end
        
        #find all exterior windows in the space and calculate their daylighting areas
        space.surfaces.each do |surface|
          if surface.outsideBoundaryCondition == "Outdoors" and surface.surfaceType == "Wall"
            surface.subSurfaces.each do |sub_surface|
              if sub_surface.handle == pri_daylight_window_info[:handle]
                #this is the primary daylight window
                runner.registerInfo("primary daylight window = #{sub_surface.name.get}")
                pri_light_sensor = OpenStudio::Model::DaylightingControl.new(model)
                pri_light_sensor.setName("#{space.name.get} Pri Daylt Sensor")
                pri_light_sensor.setSpace(space)
                pri_light_sensor.setIlluminanceSetpoint(daylight_stpt_lux)
                pri_light_sensor.setLightingControlType("2") #2 = stepped controls
                pri_light_sensor.setNumberofSteppedControlSteps(3) #all sensors 3-step per design
                window_outward_normal = sub_surface.outwardNormal
                window_centroid = OpenStudio::getCentroid(sub_surface.vertices).get
                window_outward_normal.setLength(pri_daylight_window_info[:head_height_m])
                vertex = window_centroid + window_outward_normal.reverseVector
                vertex_on_floorplane = floor_surface.plane.project(vertex)
                floor_outward_normal = floor_surface.outwardNormal
                floor_outward_normal.setLength(OpenStudio::convert(3.0, "ft", "m").get)
                sensor_vertex = vertex_on_floorplane + floor_outward_normal.reverseVector
                pri_light_sensor.setPosition(sensor_vertex)
                #TODO rotate sensor to face window (only needed for glare calcs)
                zone.setPrimaryDaylightingControl(pri_light_sensor)
                zone.setFractionofZoneControlledbyPrimaryDaylightingControl(pri_ctrl_frac)
                runner.registerInfo("added daylight sensor at point #{sensor_vertex.x},#{sensor_vertex.y},#{sensor_vertex.z}")
              elsif sec_daylight_window_info and sub_surface.handle == sec_daylight_window_info[:handle]
                #this is the secondary daylight window
                runner.registerInfo("secondary daylight window = #{sub_surface.name.get}")
                sec_light_sensor = OpenStudio::Model::DaylightingControl.new(model)
                sec_light_sensor.setName("#{space.name.get} Sec Daylt Sensor")
                sec_light_sensor.setSpace(space)
                sec_light_sensor.setIlluminanceSetpoint(daylight_stpt_lux)
                sec_light_sensor.setLightingControlType("2") #2 = stepped controls
                sec_light_sensor.setNumberofSteppedControlSteps(3) #all sensors 3-step per design
                window_outward_normal = sub_surface.outwardNormal
                window_centroid = OpenStudio::getCentroid(sub_surface.vertices).get
                window_outward_normal.setLength(pri_daylight_window_info[:head_height_m])
                vertex = window_centroid + window_outward_normal.reverseVector                
                vertex_on_floorplane = floor_surface.plane.project(vertex)
                floor_outward_normal = floor_surface.outwardNormal
                floor_outward_normal.setLength(OpenStudio::convert(3.0, "ft", "m").get)
                sensor_vertex = vertex_on_floorplane + floor_outward_normal.reverseVector
                sec_light_sensor.setPosition(sensor_vertex)
                #TODO rotate sensor to face window (only needed for glare calcs)
                zone.setSecondaryDaylightingControl(sec_light_sensor)
                zone.setFractionofZoneControlledbySecondaryDaylightingControl(sec_ctrl_frac)  
                runner.registerInfo("added daylight sensor at point #{sensor_vertex.x},#{sensor_vertex.y},#{sensor_vertex.z}")                
              end
            end #next sub_surface
          end
        end #next surface
          
        #record the fact daylight sensors were added to this zone
        spaces_daylight_sensors_added_to << space.name.get
          
      else
        runner.registerInfo("---Daylighting: NOT Applicable")
      end
    
      #blank lines for output readability
      runner.registerInfo("-")
      runner.registerInfo("-")
    
    end #next space
    
    #record the building's initial condition
    if spaces_with_daylight_potential == 0
      runner.registerAsNotApplicable("The building has no spaces with daylighting potential, this measure is not applicable.")
      return true
    else
      runner.registerInitialCondition("The building started with #{initial_spaces_with_daylight_sensors} spaces with daylight controls.  There are #{spaces_with_daylight_potential} additional spaces where daylight controls could be used.")
    end

    #record the building's final condition
    spaces_daylight_sensors_added_to_json = []
    spaces_daylight_sensors_added_to.each do |space_name|
      spaces_daylight_sensors_added_to_json << "space_name\":\"#{space_name},\""
    end
    runner.registerFinalCondition("{\"affected_spaces\": [#{spaces_daylight_sensors_added_to_json}]}")
    
    return true
 
  end #end the run method

end #end the measure

#this allows the measure to be use by the application
AddDaylightSensorstoControlLightinginPerimeterZones.new.registerWithApplication