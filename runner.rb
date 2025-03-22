require_relative "parser"
require_relative "report_generator"
require 'geocoder'

data_file = "storm_data/hurdat2-1851-2023-051124.txt"
# data_file = "storm_data/test_data.txt"

storms = Parser.new(data_file).storms
p "storm data parsed"

#Now that we have parsed the data into a useable format, go through the data to find the storms that make landfall in Florida. They must be designated hurricane (system_status = "HU") and coordinates when geocoded are in Florida (and country == United States)

#use these lat/lng bounds to reduce number of geocoder gem hits and increase speed - if we want to make this generic, we could  do an initial geocode fetch for the selected/requested state or country, or use a hard-coded lookup table if we know it's just for the US for example

def coordinates_outside_bounds?(line)

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

#here we go through our parsed data to determine what storms qualify to output into a report
@results = []

if storms.length > 0
  p "selecting storms that made landfall"
  storms.each do |storm|
    storm[:best_track_data].each do |entry|
      next if skip_storm_geocoding?(entry)

      result = Geocoder.search([entry[:latitude], entry[:longitude]]) 
      data = result.first.data

      next if data.key?("error")
      
      if data["address"]["country"] == "United States" && data["address"]["state"] == "Florida"
        @results << {name: storm[:name], date: Date.new(entry[:year], entry[:month], entry[:day]), max_wind_speed: storm[:max_wind_speed]}
        break #since we know the storm makes landfall, we don't need to check any further entries for this storm and can move on to the next storm
      end
    end
  end 

  if @results.length < 1
    p "No storms made landfall in Florida"
  elsif @results.length == 1
    p "#{@results.length} storm was determined to have made landfall in Florida"
    ReportGenerator.new(@results)
  else
    p "#{@results.length} storms were determined to have made landfall in Florida"
    ReportGenerator.new(@results)
  end
end