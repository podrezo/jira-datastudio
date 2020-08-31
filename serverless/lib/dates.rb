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
end