require "date"

class Dates
  # This format of date is used by Jira for all datetimes
  def self.parse_jira_datetime(datetime)
    re = /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2}).(\d{3})-\d{4}$/
    _, year, month, day, hour, minute, second, microsecond = re.match(datetime).to_a.map(&:to_i)
    DateTime.new(year, month, day, hour, minute, second, microsecond)
  end

  # YYYY-MM-DD is used by Google to supply date ranges for reports
  def self.parse_google_date(datetime)
    re = /^(\d{4})-(\d{2})-(\d{2})$/
    _, year, month, day = re.match(datetime).to_a.map(&:to_i)
    DateTime.new(year, month, day)
  end

  def self.diff_dates_in_seconds(start_time, end_time)
    ((end_time - start_time) * 24 * 60 * 60).to_i
  end

  def self.beginning_of_day(datetime)
    DateTime.new(datetime.year, datetime.month, datetime.day, 0, 0, 0)
  end

  def self.end_of_day(datetime)
    DateTime.new(datetime.year, datetime.month, datetime.day, 23, 59, 59)
  end

  # https://developers.google.com/datastudio/connector/reference#semantictype
  def self.format_as_google_ymd(datetime)
    datetime.strftime("%Y%m%d")
  end
end