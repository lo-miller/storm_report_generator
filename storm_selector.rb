require 'geocoder'
require 'date'

class StormSelector
  attr_reader :results
  
  def initialize(storms)
    @results = []
    select_storms(storms)
  end

  def coordinates_outside_bounds?(line)
    #use these lat/lng bounds to reduce number of geocoder gem hits and increase speed

    florida_lat_min = 24.51490854927549
    florida_lat_max = 31.000809213282125
    florida_lng_min = -87.63470035600356
    florida_lng_max = -80.03257567895679

    line[:latitude] < florida_lat_min || line[:latitude] > florida_lat_max || line[:longitude] < florida_lng_min || line[:longitude] > florida_lng_max 
  end

  #skip if the storm is not a hurricane, is before 1900, or if lat/lng are outside the rough bounds of Florida
  def skip_storm_geocoding?(entry)
    entry[:system_status] != "HU" || entry[:year] < 1900 ||coordinates_outside_bounds?(entry) 
  end

  # Here we go through our parsed data to select what storms qualify to output into a report. They must be designated as a hurricane (system_status = "HU") and coordinates when geocoded must be in Florida (and country == United States)

  def select_storms(storms)
    p "selecting storms that made landfall"
    storms.each do |storm|
      storm[:best_track_data].each do |entry|
        next if skip_storm_geocoding?(entry)

        result = Geocoder.search([entry[:latitude], entry[:longitude]]) 
        data = result.first.data

        next if data.key?("error")
        
        if data["address"]["country"] == "United States" && data["address"]["state"] == "Florida"
          @results << {name: storm[:name], date: Date.new(entry[:year], entry[:month], entry[:day]), max_wind_speed: storm[:max_wind_speed]}
          break   #since we know the storm makes landfall, we don't need to check any further entries for this storm and can move on to the next storm
        end
      end
    end 
  end
end