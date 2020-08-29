require "ostruct"
require_relative "../lib/daily_report.rb"

describe "DailyReport" do
  let (:story1_started_date) {
    DateTime.new(2018, 4, 20, 16, 20, 42)
  }
  let (:story1_finished_date) {
    DateTime.new(2018, 4, 21, 19, 42, 20)
  }
  let (:issue) {
    OpenStruct.new(
      key: "XYZ-123",
      type: "Story",
      started: story1_started_date,
      finished: story1_finished_date,
      lead_time: ((story1_finished_date - story1_started_date) * 24 * 60 * 60).to_i
    )
  }

  it "should have nothing before or after one interval" do
    report = DailyReport.new([issue])
    expected_report = [
      {
        date: "20180420",
        wip: 1,
        cumulative_finished_issues: 0,
      },
      {
        date: "20180421",
        wip: 0,
        cumulative_finished_issues: 1,
      },
    ]
    assert_equal(expected_report, report.perform)
  end

  it "should not blow up when there is just one, unfinished issue" do
    skip
  end

  it "should not blow up when there are unstarted issues" do
    skip
  end

  it "should run the report until the later of the last ended or last started story" do
    skip
  end

  describe "set_timeline" do
    it "should do something" do
      skip
    end
  end

  describe "daily_report_point" do
    it "should set a consistent point on the same day no matter the input" do
      point1 = DailyReport.daily_report_point(story1_started_date)
      point2 = DailyReport.daily_report_point(story1_finished_date)
      assert_equal(point1.hour, point2.hour)
      assert_equal(point1.minute, point2.minute)
    end
  end
end