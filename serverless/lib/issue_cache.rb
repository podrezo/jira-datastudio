require "aws-sdk-s3"

class IssueCache
  def initialize(cache_key)
    @cache_key = cache_key
    @s3 = Aws::S3::Resource.new(region: "us-east-1")
  end

  def hit?
    s3object.exists?
  end

  def age_in_seconds
    return nil unless hit?
    (Time.now - s3object.last_modified).to_i
  end

  def issues
    s3object.get(response_target: "/tmp/data.json")
    issue_hashes = JSON.parse(File.open("/tmp/data.json").read)
    issue_hashes.map do |issue_hash|
      IssueCache.issue_from_hash(issue_hash)
    end
  end

  def store(issues)
    obj = s3object
    obj.upload_stream do |write_stream|
      write_stream << JSON.generate(issues.map { |issue| IssueCache.issue_to_hash(issue) })
    end
  end

  def self.issue_to_hash(issue)
    # Single letter property names are used to lower the cost of serialization disk and transfer size
    {
      "k" => issue.key,
      "t" => issue.type,
      "s" => issue.started.nil? ? nil : Dates.format_as_google_date(issue.started),
      "f" => issue.finished.nil? ? nil : Dates.format_as_google_date(issue.finished),
      "l" => issue.lead_time,
    }
  end

  def self.issue_from_hash(issue)
    key = issue["k"]
    type = issue["t"]
    started = issue["s"].nil? ? nil : Dates.parse_google_date(issue["s"])
    finished = issue["f"].nil? ? nil : Dates.parse_google_date(issue["f"])
    lead_time = issue["l"]
    Issue.new(key, type, started, finished, lead_time)
  end

  private

  def s3object
    @s3.bucket(s3bucket).object(s3object_filename)
  end

  def s3object_filename
    "#{@cache_key}.json"
  end

  def s3bucket
    ENV["CACHE_BUCKET_NAME"]
  end
end