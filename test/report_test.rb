require_relative './test_helper'

class TestReport < Minitest::Test
  def setup    
    test_url = 'http://www.nyc.gov/html/nypd/downloads/pdf/crime_statistics/cs048pct.pdf'
    @report = Report.new(test_url)
  end

  def test_save
    VCR.use_cassette('test_save') do
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
