require 'date'

class Parser
  attr_reader :storms

  def initialize(data_file)
    @storms = []
    @storm_id = "" 
    File.foreach data_file do |line|
      if header_line?(line)   #if header line, then set storm id and parse into storms array
        @storm_id = line[0,8]     # set storm_id = to id in the first 8 spaces
        storm = parse_header_line(line)     # parse line then shovel into storms array
        storms << storm
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
      longitude: line[35] == "E" ? line[30,4].to_f : -(line[30,4].to_f), #lng is negative if in western hemisphere
      max_sustained_wind: line[38,3].to_i, #in knots
      min_pressure: line[43,4].to_i, #in millibars
      max_extent_34_kt_wind_radii: line[49..118], #this isn't needed for this app, but parsing it for future features
      max_wind_radius: line[121,4].to_i #in nautical miles
    }
  end
end