# Bring in dependencies from Bundler.
require 'bundler'
Bundler.require(:default)

# Load configuration files from `.env`.
require 'dotenv'
Dotenv.load

# Connect to MongoDB.
Mongoid.configure do |config|
  config.connect_to(ENV['MONGOHQ_URL'])
end

# Configure our S3 connection.
S3 = Fog::Storage.new({
  provider:              'AWS',
  aws_access_key_id:     ENV['S3_ACCESS_KEY_ID'],
  aws_secret_access_key: ENV['S3_SECRET_ACCESS_KEY']
})

# Bring in our data models.
Dir['./models/*.rb'].each { |file| require file }

def dir_name
  @dir_name ||= Time.now.strftime('%m-%d-%Y')
end

binding.pry

# This is the scraper portion of the application. This is meant to be run regularly
# by a cron job. 

# Download the page that lists all of the per-Precinct reports.
home = Curl.get('http://www.nyc.gov/html/nypd/html/crime_prevention/crime_statistics.shtml')
doc = Nokogiri::HTML(home.body_str)
main = doc.css('#main_content')

# Find all of the links...
main.first.css('a').each do |link|
  # ...and grab the ones that link to crime stats pdfs.
  if link['href'].match /crime_statistics\/(.*.pdf)/
    name = $1
    url  = "http://www.nyc.gov/html/nypd/downloads/pdf/crime_statistics/#{name}"
    report = Report.new_from_url(url)
    print '.' if report.save!
  end
end

puts 'All done.'
