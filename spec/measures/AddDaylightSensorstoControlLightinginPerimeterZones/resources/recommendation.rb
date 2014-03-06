
class AddDaylightSensorstoControlLightinginPerimeterZones

  def check_applicability()
  
    def initialize(model)
      @model = model
      @result = []
    end
    
    attr_accessor :result
    
    def check_applicability
    
      spaces_with_daylight_potential = 0
    
      @model.getSpaces.each do |space|
        puts "***#{space.name}***"
        num_ext_windows = 0
        total_daylight_area_m2 = 0
        existing_daylighting_controls = 0
        
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
          puts "  could not find a floor in this space"
          next #next space
        end
        
        #find all exterior windows in the space and calculate their daylighting areas
        space.surfaces.each do |surface|
          if surface.outsideBoundaryCondition == "Outdoors" and surface.surfaceType == "Wall"
            surface.subSurfaces.each do |sub_surface|
              if sub_surface.outsideBoundaryCondition == "Outdoors" and (sub_surface.subSurfaceType == "FixedWindow" or sub_surface.subSurfaceType == "OperableWindow")
                num_ext_windows += 1
                net_area_m2 = sub_surface.netArea
                puts "window #{sub_surface.name}, area = #{net_area_m2}m^2"
                 
                #find the head height and sill height of the window
                vertex_heights_above_floor = []
                sub_surface.vertices.each do |vertex|
                  vertex_on_floorplane = floor_surface.plane.project(vertex)
                  vertex_heights_above_floor << (vertex - vertex_on_floorplane).length
                end
                sill_height_m = vertex_heights_above_floor.min
                head_height_m = vertex_heights_above_floor.max
                puts "  head height = #{head_height_m}m, sill height = #{sill_height_m}"
                
                #find the width of the window
                if not sub_surface.vertices.size == 4
                  puts "cannot handle windows with #{sub_surface.vertices.size} vertices"
                  next
                end
                prev_vertex_on_floorplane = nil
                max_width_m = 0
                sub_surface.vertices.each do |vertex|
                  vertex_on_floorplane = floor_surface.plane.project(vertex)
                  if not prev_vertex_on_floorplane
                    prev_vertex_on_floorplane = vertex_on_floorplane
                    next
                  end
                  width_m = (prev_vertex_on_floorplane - vertex_on_floorplane).length
                  if width_m > max_width_m
                    max_width_m = width_m
                  end
                end
                max_width_plus_side_m = max_width_m + OpenStudio::convert(4,"ft","m").get
                max_width_plus_side_ft = OpenStudio::convert(max_width_plus_side_m,"ft","m").get
                puts "  width plus 2ft on sides = #{max_width_plus_side_ft}ft"
                
                #find the daylighting area of the window
                window_daylight_area_m2 = head_height_m * max_width_plus_side_m
                total_daylight_area_m2 += window_daylight_area_m2
                            
              end      
            end #next sub-surface
          end
        end #next surface

        #find existing daylighting controls
        existing_daylighting_controls = space.daylightingControls.size

        #warn if daylight area greater than space floor area
        #this could happen with tall rooms, large windows on all sides, etc
        if total_daylight_area_m2 > space.floorArea
          puts "  daylight area > floor area; floor area is 100% daylightable"
          total_daylight_area_m2 = space.floorArea
        end
        
        #convert daylight area to IP
        total_daylight_area_ft2 = OpenStudio::convert(total_daylight_area_m2,"m^2","ft^2").get
        
        #report out a summary of the space
        puts "  space has #{num_ext_windows} exterior windows"
        puts "  space has #{existing_daylighting_controls} existing daylighting controls"
        puts "  space has #{total_daylight_area_ft2}ft^2 of daylight area"
        
        #Conditions for daylighting to be applicable
        # 1. Has vertical fenestration
        # 2. Without daylighting controls
        # 3. Daylight Area exceeds 250 sq.ft 
        if num_ext_windows > 0 and total_daylight_area_ft2 > 250.0 and existing_daylighting_controls == 0
          spaces_with_daylight_potential += 1
          return "    DAYLIGHTING APPLICABLE"
        end
        
      end #next space

      
      puts  "summary - model has #{spaces_with_daylight_potential} spaces with daylighting potential"
      if spaces_with_daylight_potential > 0
        @result = "Applicable"
      else
        @result = "Not Applicable"
      end
      puts "*********#{model_path}***********"
      puts ""  
    
    end #end check_applicability

  end #class MeasureApplicabilityChecker

end #module AddDaylightSensorstoControlLightinginPerimeterZones