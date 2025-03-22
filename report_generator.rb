require 'csv'

class ReportGenerator

  def initialize(data)
    CSV.open("reports/florida_hurricanes_#{DateTime.now()}.csv", "wb") do |csv|
      csv << data.first.keys # adds the attributes name on the first line
      data.each do |hash|
        csv << hash.values
      end
    end

    p "csv file created with name 'florida_hurricanes.csv'"
  end
end


