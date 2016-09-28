require 'minitest/autorun'
require 'vcr'
require_relative '../environment'

Bundler.require(:test)

VCR.configure do |config|
  config.cassette_library_dir = File.expand_path('./fixtures/cassettes', File.dirname(__FILE__))
  config.hook_into :webmock
  config.filter_sensitive_data('<S3_ACCESS_KEY_ID>') { ENV['S3_ACCESS_KEY_ID'] }
  config.filter_sensitive_data('<S3_SECRET_ACCESS_KEY>') { ENV['S3_SECRET_ACCESS_KEY'] }
  config.filter_sensitive_data('<S3_BUCKET>') { ENV['S3_BUCKET'] }
end
