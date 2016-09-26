require_relative './test_helper'

class TestReport < Minitest::Test
  def setup
    VCR.insert_cassette(name)
    test_url = 'http://www.nyc.gov/html/nypd/downloads/pdf/crime_statistics/cs-en-us-042pct.pdf'
    @report = Report.new(test_url)
  end

  def test_save
    assert_equal @report.save, true
  end

  def test_name
    assert_equal @report.name, 'cs-en-us-042pct.pdf'
  end

  def test_public_url
    assert_includes @report.public_url, 'cs-en-us-042pct.pdf'
  end

  def teardown
    VCR.eject_cassette(name)
  end
end
