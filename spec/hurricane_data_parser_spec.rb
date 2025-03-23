require 'rspec'
require 'spec_helper.rb' 
require_relative '../hurricane_data_parser.rb' 

describe "parsing" do

  describe "header_line?" do
    it "returns true for a header line" do
      line = "AL112009,                IDA,     31,"
      expect(header_line?(line)).to eq(true)
    end
    it "returns false for a best track entry line" do
      line = "20091104, 0600,  , TD, 11.0N,  81.0W,  30, 1007,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0, -999"
      expect(header_line?(line)).to eq(false)
    end
  end

  describe "parse_header_line" do
    it "returns the correct data for a header line" do
      line = "AL112009,                IDA,     31,"
      expect(parse_header_line(line)).to eq({
        storm_id: nil, 
        basin: "AL",
        cyclone_number: 11,
        year: 2009,
        name: "IDA",
        max_wind_speed: 0,
        best_track_entries: 31,
        best_track_data: []
      })
    end
  end
  
  describe "parse_best_track_entry" do
    it "returns the correct data for a best track data entry line" do
      line = "20091104, 0600,  , TD, 11.0N,  81.0W,  30, 1007,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0, -999"
      expect(parse_best_track_entry(line)).to eq({
        storm_id: nil,
        year: 2009,
        month: 11,
        day: 04,
        hours_utc: 06,
        minutes: 00,
        record_identifier: nil, 
        system_status: "TD",
        latitude: 11.0,
        longitude: -81.0,
        max_sustained_wind: 30,
        min_pressure: 1007,
        max_extent_34_kt_wind_radii: "   0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0",
        max_wind_radius: -999
      })
    end
  end
  
  describe "parse_storms" do
    it "returns the expected number of storms" do
      @storms = []
      parse_storms("storm_data/test_data.txt")
      expect(@storms.length).to eq(5)
    end
    it "returns the expected number of best track data entry per storm" do
      @storms = []
      parse_storms("storm_data/test_data.txt")
      expect(@storms.last[:best_track_data].count).to eq(@storms.last[:best_track_entries])
    end
  end
end

describe "storm selection" do
  storm = { 
    storm_id: "AL142018", 
    basin: "AL", cyclone_number: 14, 
    year: 2018, 
    name: "MICHAEL", 
    max_wind_speed: 140, 
    best_track_entries: 38, 
    best_track_data: [
      {storm_id: "AL142018", year: 2018, month: 10, day: 6, hours_utc: 18, minutes: 0, record_identifier: nil, system_status: "LO", latitude: 17.8, longitude: -86.0, max_sustained_wind: 25, min_pressure: 1006, max_extent_34_kt_wind_radii: "   0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0", max_wind_radius: -999}, 
      {storm_id: "AL142018", year: 2018, month: 10, day: 7, hours_utc: 6, minutes: 0, record_identifier: nil, system_status: "TD", latitude: 18.4, longitude: -86.0, max_sustained_wind: 30, min_pressure: 1004, max_extent_34_kt_wind_radii: "   0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0", max_wind_radius: -999}, 
      {storm_id: "AL142018", year: 2018, month: 10, day: 8, hours_utc: 12, minutes: 0, record_identifier: nil, system_status: "HU", latitude: 20.4, longitude: -85.0, max_sustained_wind: 65, min_pressure: 982, max_extent_34_kt_wind_radii: "   0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0", max_wind_radius: -999}, 
      {storm_id: "AL142018", year: 2018, month: 10, day: 8, hours_utc: 18, minutes: 0, record_identifier: nil, system_status: "HU", latitude: 28.5, longitude: -81.4, max_sustained_wind: 75, min_pressure: 977, max_extent_34_kt_wind_radii: "   0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0", max_wind_radius: -999}
    ]
  }

  describe "coordinates_outside_bounds?" do
    it "returns false for a storm with coordinates inside of the given bounds" do
      expect(coordinates_outside_bounds?(storm[:best_track_data][3])).to eq(false)
    end
    it "returns true for a storm with a latitude outside of the coordinate bounds" do
      storm[:best_track_data][2][:latitude] = 47.6
      expect(coordinates_outside_bounds?(storm[:best_track_data][2])).to eq(true)
    end
    it "returns true for a storm with a longitude outside of the coordinate bounds" do
      storm[:best_track_data][2][:longitude] = -122.3
      expect(coordinates_outside_bounds?(storm[:best_track_data][2])).to eq(true)
    end
  end

  describe "skip_storm_geocoding?" do
    it "returns false for a hurricane that makes landfall in Florida after 1900" do
      expect(skip_storm_geocoding?(storm[:best_track_data][3])).to eq(false)
    end
    it "returns true for a storm before 1900" do
      storm[:best_track_data][2][:year] = 1860
      expect(skip_storm_geocoding?(storm[:best_track_data][2])).to eq(true)
    end
    it "returns true for a storm that is not a hurricane" do
      storm[:best_track_data][2][:year] = 1930
      storm[:best_track_data][3][:system_status] = "TD"
      expect(skip_storm_geocoding?(storm[:best_track_data][3])).to eq(true)
    end
    it "returns true for a storm with a latitude outside of the coordinate bounds" do
      storm[:best_track_data][2][:system_status] = "HU"
      expect(skip_storm_geocoding?(storm[:best_track_data][2])).to eq(true)
    end
    it "returns true for a storm with a longitude outside of the coordinate bounds" do
      expect(skip_storm_geocoding?(storm[:best_track_data][2])).to eq(true)
    end
  end
end
