#!/usr/bin/env ruby
# coding: utf-8

require "tempfile"
require "bundler"
Bundler.require(:default)
include Mongo

@connection ||= Fog::Storage.new({
  provider:              "AWS",
  aws_access_key_id:     ENV["S3_ACCESS_KEY_ID"],
  aws_secret_access_key: ENV["S3_SECRET_ACCESS_KEY"]
})

def dir_name
  @dir_name ||= Time.now.strftime("%m-%d-%Y")
end

def build_or_set_dir
  unless Dir.exists? dir_name
    Dir.mkdir dir_name
  end  
end

def setup_database
  @database_client = MongoClient.new("localhost", 27017)
  @database = @database_client.db("nyc-compstat")
  @reports = @database['reports']
end

def download_pdfs
  setup_database
  home = Curl.get "http://www.nyc.gov/html/nypd/html/crime_prevention/crime_statistics.shtml"
  doc = Nokogiri::HTML home.body_str
  main = doc.css("#main_content")
  main.first.css("a").each do |link|
    build_or_set_dir
    if link["href"].match /crime_statistics\/(.*.pdf)/
      name = $1
      url  = "http://www.nyc.gov/html/nypd/downloads/pdf/crime_statistics/#{name}"
      file = Tempfile.new(ENV["S3_BUCKET"]) # File.new(name, "w+")
      
      # download / parse / persist
      request = Curl::Easy.http_get(url)
      file.write(request.body_str)

      begin
        parse_pdf(file)
      rescue Exception => e
        puts e.inspect
      end

      store_pdf(file)
      
      # clean up
      file.close; file.unlink # File.delete(name)
      
      print "."      
    end
  end
  puts "all done"
end

def get_column_names(set_of_rows)
  # ap set_of_rows
  more = set_of_rows[26].join(" ")
  #ap more

  [
   "Week to Date, #{set_of_rows[18][0]}",
   "Week to Date, #{set_of_rows[18][1]}",
   "Week to Date, Percent Change",
   "28 Day, #{set_of_rows[18][4]}",
   "28 Day, #{set_of_rows[18][5]}",
   "28 Day, Percent Change",
   "Year to Date, #{set_of_rows[18][8]}",
   "Year to Date, #{set_of_rows[18][9]}",
   "Year to Date, Percent Change",
   "2 Year Percent Change",
   "12 Year Percent Change",
   "20 Year Percent Change"
  ] + set_of_rows[42][0..4]
end

# takes in a row and spits out a name and columns of data
def process_row(row)
  # name = ""
  
  # { "foo",
  #   :columns => [] }
end

def parse_pdf(file)
  PDF::Reader.open(file) do |reader|
    reader.pages.each do |page|
      lines = []
      page.text.each_line do |line|
        pieces = line.split
        lines << pieces
      end

      # ap lines

      thing = {
        :volume => lines[11][1],
        :series_number => lines[11][3],
        :precinct => lines[11][4],
        :start_date => lines[14][4],
        :end_date => lines[14][6],
        :column_names => get_column_names(lines),
        :row_names => nil,
        :data => lines[17..56]
      }
      
      #ap path_to_pdf
      #ap thing
      @reports.insert(thing)
    end
  end
end

# Stores a PDF on S3.
# Takes in a File and returns an Fog::Storage::AWS::File.
def store_pdf(disk_file)
  directory = @connection.directories.create({
    :key    => ENV["S3_BUCKET"],
    :public => true
  })                                               

  s3_file = directory.files.create(
    :key    => dir_name + "/" + File.basename(disk_file.path),
    :body   => disk_file,
    :public => true
  )
end

download_pdfs
