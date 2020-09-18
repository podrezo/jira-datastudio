require "date"

class Dates
  # This format of date is used by Jira for all datetimes
  def self.parse_jira_datetime(datetime)
    re = /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2}).\d{3}-\d{4}$/
    _, year, month, day, hour, minute, second = re.match(datetime).to_a.map(&:to_i)
    DateTime.new(year, month, day, hour, minute, second)
  end

  # YYYY-MM-DD is used by Google to supply date ranges for reports
  def self.parse_google_date(datetime)
    re = /^(\d{4})-(\d{2})-(\d{2})$/
    _, year, month, day = re.match(datetime).to_a.map(&:to_i)
    DateTime.new(year, month, day)
  end

  def self.lead_time(start_time, end_time)
    # Lead time should ignore weekends
    ignore_days = ["6", "7"] # 6 = Sat, 7 = Sun
    seconds_in_a_day = 24*60*60
    total_seconds = ((end_time - start_time) * seconds_in_a_day).to_i
    # Do not iterate right up to the last day because if we end on a weekend we don't want to subtract that day
    (start_time .. (end_time - 1)).step(1).to_a.each do |dt|
      total_seconds -= seconds_in_a_day if ignore_days.include?(dt.strftime("%u"))
    end
    total_seconds
  end

  def self.beginning_of_day(datetime)
    DateTime.new(datetime.year, datetime.month, datetime.day, 0, 0, 0)
  end

  def self.end_of_day(datetime)
    DateTime.new(datetime.year, datetime.month, datetime.day, 23, 59, 59)
  end

  # https://developers.google.com/datastudio/connector/reference#semantictype
  def self.format_as_datastudio_ymd(datetime)
    datetime.strftime("%Y%m%d")
  end

  # Only referred to as google date since that's the format Google happens to use
  # for passing date ranged. However, this code is actually used to make it simpler
  # to deseralize and serialize issues for caching. Re-using the same date format
  # means less code to maintain
  def self.format_as_google_date(datetime)
    datetime.strftime("%Y-%m-%d")
  end
end