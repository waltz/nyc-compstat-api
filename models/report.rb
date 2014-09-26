class Report
  include Mongoid::Document
  before_create :upload_to_s3

  field :remote_url, type: String

  class << self
    # Create a new report from a PDF url.
    def new_from_url(url)      
      begin
        # Download the file at the url to a temp file.
        file = Tempfile.new(url)
        curl = Curl::Easy.new(url)
        curl.perform
        file.write(curl.body_str)
        
        # Hand the file off to the uploader/parser.
        new_from_pdf(file)
      ensure
        # Close and delete the temp file.
        file.close
        file.unlink
      end
    end

    # Returns a new report given a PDF file.
    def new_from_pdf(file)
      connection = Fog::Storage.new({
        :provider              => 'AWS',
        :aws_access_key_id     => ENV['S3_ACCESS_KEY_ID'],
        :aws_secret_access_key => ENV['S3_SECRET_ACCESS_KEY']
     })
    end

    # Turn a PDF file into an multi dimensional array.
    def parse_pdf(file)
      lines = []
      PDF::Reader.open(file) do |reader|
        reader.pages.first.text.each_line do |line|
          pieces = line.split
          lines << pieces
        end
      end
      lines
    end
    
    # Morph a garbled array in to recognizable attributes and
    # return them as a hash.
    def extract_data(array)
      {
        :volume => lines[11][1],
        :series_number => lines[11][3],
        :precinct => lines[11][4],
        :start_date => lines[14][4],
        :end_date => lines[14][6],
        :column_names => get_column_names(lines),
        :row_names => nil,
        :data => lines[17..56]
      }
    end
  end

  protected

  # Uploads the current file to S3 and tracks the url.
  def upload_to_s3
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
end
