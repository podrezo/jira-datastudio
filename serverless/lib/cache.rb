require "aws-sdk-s3"

class Cache
  def initialize(cache_key)
    @cache_key = cache_key
    @s3 = Aws::S3::Resource.new(region: "us-east-1")
  end

  def hit?
    false
  end

  def issues
    []
  end

  def store(issues)
    obj = @s3.bucket(ENV["CACHE_BUCKET_NAME"]).object("#{@cache_key}.json")
    obj.upload_stream do |write_stream|
      write_stream << JSON.generate(issues.map(&:to_hash))
    end
  end
end