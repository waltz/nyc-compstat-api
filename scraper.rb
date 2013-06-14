#!/usr/bin/env ruby
# coding: utf-8

require "bundler"
Bundler.require(:default)

def dir_name
  @dir_name ||= Time.now.strftime("%m-%d-%Y")
end

def build_or_set_dir
  unless Dir.exists? dir_name
    Dir.mkdir dir_name
  end  
end

def download_pdfs
  home = Curl.get "http://www.nyc.gov/html/nypd/html/crime_prevention/crime_statistics.shtml"
  doc = Nokogiri::HTML home.body_str
  main = doc.css("#main_content")
  main.first.css("a").each do |link|
    build_or_set_dir
    if link["href"].match /crime_statistics\/(.*.pdf)/
      url  = "http://www.nyc.gov/html/nypd/downloads/pdf/crime_statistics/#{$1}"
      file = "./#{dir_name}/#{$1}"
      Curl::Easy.download(url, file)
      parse_pdf(file)
      print "."  
      exit
    end
  end
  puts "all done"
end

def get_column_names(set_of_rows)
  # ap set_of_rows
  more = set_of_rows[26].join(" ")
  ap more

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

def parse_pdf(path_to_pdf)
  PDF::Reader.open(path_to_pdf) do |reader|
    reader.pages.each do |page|
      lines = []
      puts "=" * 20
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
      
      ap path_to_pdf
      ap thing
    end
  end
end

download_pdfs
