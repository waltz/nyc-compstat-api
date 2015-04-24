require './environment'

# This is the scraper portion of the application. This is meant to be run regularly
# by a cron job. 

# Download the page that lists all of the per-Precinct reports.
home = Net::HTTP.get(URI('http://www.nyc.gov/html/nypd/html/crime_prevention/crime_statistics.shtml'))
doc = Nokogiri::HTML(home)
main = doc.css('#main_content')

# Find all of the links...
main.first.css('a').each do |link|
  # ...and grab the ones that link to crime stats pdfs.
  if link['href'].match /crime_statistics\/(.*.pdf)/
    name = $1
    url  = "http://www.nyc.gov/html/nypd/downloads/pdf/crime_statistics/#{name}"
    puts "Found URL: #{url}"
    report = Report.new(url)

    if report.save
      puts "Saved a new report to #{report.public_url}"
    else
      puts 'There were problems saving the report.'
      p report
    end
  end
end

puts 'All done.'
