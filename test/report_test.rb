require 'minitest/autorun'
require 'vcr'
require_relative '../environment'

VCR.configure do |config|
  config.cassette_library_dir = File.expand_path('./fixtures/vcr_cassettes', File.dirname(__FILE__))
  config.hook_into :webmock
end

class TestReport < Minitest::Test
  def setup    
    test_url = 'http://www.nyc.gov/html/nypd/downloads/pdf/crime_statistics/cs048pct.pdf'
    @report = Report.new(test_url)
  end

  def test_save
    vcr.use_cassette('test_save') do
      assert_equal @report.save, true
    end
  end

  def test_name
    VCR.use_cassette('name') do
      assert_equal @report.name, 'cs048pct.pdf'
    end
  end

  def test_public_url
    VCR.use_cassette('public_url') do
      assert_includes @report.public_url, 'cs048pct.pdf'
    end    
  end
end
