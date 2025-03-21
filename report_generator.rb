require 'csv'
# require 'prawn'   --> looking into how to export as a pdf using Prawn gem - would be a next step

class ReportGenerator

  def initialize(data)
    CSV.open("florida_hurricanes.csv", "wb") do |csv|
      csv << data.first.keys # adds the attributes name on the first line
      data.each do |hash|
        csv << hash.values
      end
    end

    p "csv file created with name 'florida_hurricanes.csv'"
  end
end


