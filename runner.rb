require_relative "parser"
require_relative "storm_selector"
require_relative "report_generator"

# data_file = "storm_data/hurdat2-1851-2023-051124.txt"
data_file = "storm_data/test_data.txt"

storms = Parser.new(data_file).storms
p "storm data parsed"

#Now that we have parsed the data into a useable format, go through the data to find the storms that make landfall in Florida. 

if storms.length > 0

  results = StormSelector.new(storms).results

  if results.length < 1
    p "No storms made landfall in Florida"
  elsif results.length == 1
    p "#{results.length} storm was determined to have made landfall in Florida"
    ReportGenerator.new(results)
  else
    p "#{results.length} storms were determined to have made landfall in Florida"
    ReportGenerator.new(results)
  end
end