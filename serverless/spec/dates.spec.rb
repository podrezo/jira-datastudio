require_relative "../lib/dates.rb"

describe "Dates" do
  describe "parse_jira_datetime" do
    it "should strip timezone information" do
      assert_equal("2020-08-27T11:23:36+00:00", Dates.parse_jira_datetime("2020-08-27T11:23:36.012-0400").to_s)
    end
  end

  describe "parse_google_date" do
    it "should strip timezone information" do
      assert_equal("2020-08-27T00:00:00+00:00", Dates.parse_google_date("2020-08-27").to_s)
    end
  end

  describe "diff_dates_in_seconds" do
    it "should return 86400 seconds for one day" do
      assert_equal(86400, Dates.diff_dates_in_seconds(DateTime.new(2018,4,20), DateTime.new(2018,4,21)))
    end
  end
end