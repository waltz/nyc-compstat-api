class Report < Struct.new(:url)
  def save
    file.save
  end

  def public_url
    file.public_url
  end

  def file    
    @file ||= bucket.files.new(
      key:    key,
      body:   original,
      public: true,
    )
  end

  def key
    directory_name + '/' + name
  end

  def name
    url.split('/').last
  end

  def directory_name
    Time.now.strftime('%m-%d-%Y')    
  end

  def original
    @original ||= Net::HTTP.get(URI(url))
  end

  def bucket
    @bucket ||= connection.directories.get(ENV['S3_BUCKET'])
  end

  def connection
    @connection ||= Fog::Storage.new({
      provider:              'AWS',
      aws_access_key_id:     ENV['S3_ACCESS_KEY_ID'],
      aws_secret_access_key: ENV['S3_SECRET_ACCESS_KEY'],
    })
  end
end
