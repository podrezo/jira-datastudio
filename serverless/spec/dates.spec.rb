require_relative "../lib/dates.rb"

describe "Dates" do
  describe "parse_jira_datetime" do
    it "should strip timezone information" do
      assert_equal("2020-08-27T11:23:36+00:00", Dates.parse_jira_datetime("2020-08-27T11:23:36.012-0400").to_s)
    end
    it "should not be thrown off by the microseconds part" do
      # This is from a bug. If you pass a 7th parameter to DateTime.new it interprets it as microseconds
      # which is not really relevant for us, but was being parsed nonetheless. However, if your microseconds happens
      # to be exactly 1 then ruby interprets it as a timezone and ends up skewing the date we get by an entire day
      # leading to wrong results like having a finished date before the started date
      assert_equal("2018-06-20T13:46:09+00:00", Dates.parse_jira_datetime("2018-06-20T13:46:09.001-0400").to_s)
    end
  end

  describe "parse_google_date" do
    it "should strip timezone information" do
      assert_equal("2020-08-27T00:00:00+00:00", Dates.parse_google_date("2020-08-27").to_s)
    end
  end

  describe "format_as_google_date" do
    it "should format as YYYY-MM-DD" do
      assert_equal("2018-04-20", Dates.format_as_google_date(DateTime.new(2018, 4, 20, 16, 20, 42)))
    end
  end

  describe "lead_time" do
    it "should return 86400 seconds for one day" do
      assert_equal(86400, Dates.lead_time(DateTime.new(2018,4,19), DateTime.new(2018,4,20)))
    end

    it "should work when bordering a weekend" do
      assert_equal(86400, Dates.lead_time(DateTime.new(2018,4,20), DateTime.new(2018,4,21)))
    end

    it "should ignore weekends (saturday, sunday)" do
      # Friday at midnight to midnight on wednesday should be 3 full days
      assert_equal(3*24*60*60, Dates.lead_time(DateTime.new(2018,4,20), DateTime.new(2018,4,25)))
    end

    it "should not ignore partial time if finishing on a weekend" do
      # Friday at midnight to noon on sunday should be 1.5 full days
      assert_equal(1.5*24*60*60, Dates.lead_time(DateTime.new(2018,4,20), DateTime.new(2018,4,22, 12, 0, 0)))
    end
  end

  describe "beginning_of_day" do
    it "should be able to set a 'beginning of the day' on a date" do
      d = Dates.beginning_of_day(DateTime.new(2018, 4, 20, 16, 20, 42))
      assert_equal(2018, d.year)
      assert_equal(4, d.month)
      assert_equal(20, d.day)
      assert_equal(0, d.hour)
      assert_equal(0, d.minute)
      assert_equal(0, d.second)
    end
  end

  describe "end_of_day" do
    it "should be able to set a 'end of the day' on a date" do
      d = Dates.end_of_day(DateTime.new(2018, 4, 20, 16, 20, 42))
      assert_equal(2018, d.year)
      assert_equal(4, d.month)
      assert_equal(20, d.day)
      assert_equal(23, d.hour)
      assert_equal(59, d.minute)
      assert_equal(59, d.second)
    end
  end

  describe "format_as_datastudio_ymd" do
    it "should be able to format datetimes for google YEAR_MONTH_DAY format" do
      assert_equal("20180420", Dates.format_as_datastudio_ymd(DateTime.new(2018, 4, 20, 16, 20, 42)))
    end
  end
end