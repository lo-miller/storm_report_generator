require 'rspec'
require 'spec_helper.rb' 
require_relative '../hurricane_data_parser_2.rb' 

# frozen_string_literal: true

describe "parsing" do

  describe "header_line?" do
    it "returns true for a header line" do
      # p test_in_file
      # parser = Parser.new(test_in_file) 
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
  describe "skip_storm_geocoding?" do
    
  end
end
