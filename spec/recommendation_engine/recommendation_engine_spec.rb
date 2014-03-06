require 'spec_helper'
require 'faraday'
require 'logger'


describe "BCL API" do
  context "::Component" do
    before :all do
      @model_paths = []
      @model_paths << "#{Dir.pwd}/as_current_Perimeter_Core.osm"
      @model_paths << "#{Dir.pwd}/as_current_Single_Zone.osm"
      @model_paths << "#{Dir.pwd}/daylighting_test_model_1.osm"
    end

    context "apply measures" do
      it "should recommend an upgrade" do
        @model_paths.each do |model_path|
          puts "*********#{model_path}***********"

          spaces_with_daylight_potential = 0

          
          model = safe_load_model(model_path)

          re = RecommendationEngine.new(model)

        end

      end
    end
  end
end

  



