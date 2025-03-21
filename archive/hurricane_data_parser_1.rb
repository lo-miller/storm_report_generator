data_file = "test_data.txt"

storms = []
best_track_data = []
storm_id = ""

File.foreach data_file do |line|
  line.chomp!
  #if header line, then set storm id and parse into storms array
  if line.length <= 40 &&   #header line starts with "AL" in this case - or length is only 38 spaces total for more flexibility.  check if less than 40 in case #of storms increases by a digit space
    storm_id = line[0,8]     # set storm_id = to  id in the first 8 spaces
    # parse line then shovel into storms array
    storm = {
      storm_id: storm_id, 
      basin: line[0,2],
      cyclone_number: line[2,2].to_i,
      year: line[4,4].to_i,
      name: line[18,10].strip!,
      best_track_entries: line[33,3].to_i
    }
    storms << storm
  else
    #parse into best track entry then shovel into best_track_data array
    best_track_entry = {
      storm_id: storm_id, #set from last line that was a header line 
      year: line[0,4].to_i,
      momth: line[4,2].to_i,
      day: line[6,2].to_i,
      hours_utc: line[10,2].to_i,
      minutes: line[12,2].to_i,
      time_utc: line[10,4].to_i,
      record_identifier: line[16].empty? ? line[16] : nil, #“L” = landfall, but don’t use this identifier for this exercise (1851 - 1970, 1991 onward)
      system_status: line[19,2], #“HU” = hurricane-level storm
      latitude: line[27] == "N" ? line[23,4].to_f : -(line[23,4].to_f), #lat is negative if in southern hemisphere
      longitude: line[35] == "E" ? line[30,4].to_f : -(line[30,4].to_f), #lng is negative if in western hemisphere
      max_sustained_wind: line[38,3].to_i, #in knots
      min_pressure: line[43,4].to_i, #in millibars
      max_extent_34_kt_wind_radii: line[49..118], #this isn't needed for this app, but parsing it for future features
      max_wind_radius: line[121,4].to_i #in nautical miles
    }
    best_track_data << best_track_entry
  end
end
