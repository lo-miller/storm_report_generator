require 'geocoder'
require 'date'
require 'csv'
require 'rspec'
require './spec/spec_helper'
# require 'prawn'

Geocoder.configure(always_raise: :all)

# data_file = "storm_data/hurdat2-1851-2023-051124.txt"
data_file = "storm_data/test_data.txt"

@storms = []
@storm_id = ""
 
def header_line?(line)
  line.length <= 40 #header line length is only 38 spaces total. For more flexibility, check if less than 40 
end

def parse_header_line(line)
  {
    storm_id: @storm_id, 
    basin: line[0,2],
    cyclone_number: line[2,2].to_i,
    year: line[4,4].to_i,
    name: line[18,10].strip!,
    max_wind_speed: 0, #set this to 0 initially and set to highest max_sustained_wind we find in best track data entries for this storm. this is in knots
    best_track_entries: line[33,3].to_i,
    best_track_data: []
  }
end

def parse_best_track_entry(line)
  {
    storm_id: @storm_id, #set from last line that was a header line 
    year: line[0,4].to_i,
    month: line[4,2].to_i,
    day: line[6,2].to_i,
    hours_utc: line[10,2].to_i,
    minutes: line[12,2].to_i,
    record_identifier: line[16].empty? ? line[16] : nil, #“L” = landfall, but don’t use this identifier for this exercise (1851 - 1970, 1991 onward)
    system_status: line[19,2], #“HU” = hurricane-level storm
    latitude: line[27] == "N" ? line[23,4].to_f : -(line[23,4].to_f), #lat is negative if in southern hemisphere
    longitude: line[35] == "E" ? line[30,4].to_f : -(line[30,4]).to_f, #lng is negative if in western hemisphere
    max_sustained_wind: line[38,3].to_i, #in knots
    min_pressure: line[43,4].to_i, #in millibars
    max_extent_34_kt_wind_radii: line[49..118], #this isn't needed for this app, but parsing it for future features
    max_wind_radius: line[121,4].to_i #in nautical miles
  }
end

def parse_storms(data_file)
  File.foreach data_file do |line|
    if header_line?(line)   #if header line, then set storm id and parse into storms array
      @storm_id = line[0,8]     # set storm_id = to id in the first 8 spaces
      storm = parse_header_line(line)     # parse line then shovel into storms array
      @storms << storm
    else    
      best_track_entry = parse_best_track_entry(line)     #parse into best track entry then shovel into best_track_data array
      @storms.last[:best_track_data] << best_track_entry
      #set max wind speed for storm equal to the highest max wind speed we find in all best track entries for that storm
      if best_track_entry[:max_sustained_wind] > @storms.last[:max_wind_speed]
        @storms.last[:max_wind_speed] = best_track_entry[:max_sustained_wind]
      end
    end
  end
end

parse_storms(data_file)

#Now that we have parsed the data into a useable format, go through the data to find the storms that make landfall in Florida. They must be designated hurricane (system_status = "HU") and coordinates when geocoded are in Florida (and country == United States)

#use these lat/lng bounds to reduce number of geocoder gem hits and increase speed - if we want to make this generic, we could  do an initial geocode fetch for the selected/requested state or country, or use a hard-coded lookup table if we know it's just for the US for example

@florida_lat_min = 24.51490854927549
@florida_lat_max = 31.000809213282125
@florida_lng_min = -87.63470035600356
@florida_lng_max = -80.03257567895679

def coordinates_outside_bounds?(line)
  line[:latitude] < @florida_lat_min || line[:latitude] > @florida_lat_max || line[:longitude] < @florida_lng_min || line[:longitude] > @florida_lng_max 
end

#skip if the storm is not a hurricane, is before 1900, or if lat/lng are outside the rough bounds of Florida. 
def skip_storm_geocoding?(entry)
  entry[:system_status] != "HU" || entry[:year] < 1900 ||coordinates_outside_bounds?(entry) 
end

@results = []

@storms.each do |storm|
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

def generate_report(data)
  CSV.open("florida_hurricanes.csv", "wb") do |csv|
    csv << data.first.keys # adds the attributes name on the first line
    data.each do |hash|
      csv << hash.values
    end
  end
end

generate_report(@results)
