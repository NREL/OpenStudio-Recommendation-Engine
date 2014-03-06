require 'spec_helper'

describe "BCL API" do
  context "::Component" do
    before :all do
      @model_paths = []
      @model_paths << "#{__FILE__}/as_current_Perimeter_Core.osm"
      @model_paths << "#{__FILE__}/as_current_Single_Zone.osm"
      @model_paths << "#{__FILE__}/daylighting_test_model_1.osm"
      @path_to_measure = "#{File.dirname(__FILE__)}/../measures"
    end

    context "apply measures" do
      it "should find measures to run" do
        osr = OpenStudio::RecommendationEngine::RecommendationEngine.new(nil, @path_to_measure)
        #expect{OpenStudio::RecommendationEngine::RecommendationEngine.new(nil, @path_to_measure)}.to raise_exception 
        
      end
      
      it "should recommend an upgrade" do
        @model_paths.each do |model_path|
          puts "*********#{model_path}***********"
          
          #OpenStudio::safe_load_model(model_path)


        end

      end
    end
  end
end

  



