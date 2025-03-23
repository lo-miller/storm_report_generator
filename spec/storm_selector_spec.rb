require_relative '../storm_selector.rb'
require 'rspec'
require 'date'
require 'geocoder'
require 'spec_helper.rb' 

# frozen_string_literal: true

describe StormSelector do
  let!(:storms) { [{
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
  }]}

  let!(:expected_results) {
    [{name: "MICHAEL", max_wind_speed: 140, date: Date.new(2018,10,8)}]
  }

  it "returns a storm that makes landfall in Florida after 1900 and is a hurricane" do
    results = StormSelector.new(storms).results
    expect(results).to eq(expected_results)
  end

  it "does not return a storm with coordinates outside of the given bounds" do
    storms[0][:best_track_data][2][:latitude] = 47.6
    storms[0][:best_track_data][3][:longitude] = -122.3
    results = StormSelector.new(storms).results
    expect(results).to eq([])
  end

  it "does not return a storm that is before the year 1900" do
    storms[0][:best_track_data][2][:year] = 1860
    storms[0][:best_track_data][3][:year] = 1860
    results = StormSelector.new(storms).results
    expect(results).to eq([])
  end

  it "does not return a storm with that is not a hurricane" do
    storms[0][:best_track_data][2][:system_status] = "TD"
    storms[0][:best_track_data][3][:system_status] = "TD"
    results = StormSelector.new(storms).results
    expect(results).to eq([])
  end

  it "does not return a storm with that does not hit Florida" do
    storms[0][:best_track_data][2][:latitude] = 28.9
    storms[0][:best_track_data][2][:latitude] = 28.9
    storms[0][:best_track_data][3][:longitude] = -84.2
    storms[0][:best_track_data][3][:longitude] = -84.2
    results = StormSelector.new(storms).results
    expect(results).to eq([])
  end
end
