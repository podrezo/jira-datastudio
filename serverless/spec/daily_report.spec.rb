require "ostruct"
require_relative "../lib/daily_report.rb"

describe "DailyReport" do
  let (:issue1_started_date) {
    DateTime.new(2018, 4, 20, 16, 20, 42)
  }
  let (:issue1_finished_date) {
    DateTime.new(2018, 4, 21, 19, 42, 20)
  }
  let (:issue1) {
    OpenStruct.new(
      key: "XYZ-123",
      type: "Story",
      started: issue1_started_date,
      finished: issue1_finished_date,
      lead_time: ((issue1_finished_date - issue1_started_date) * 24 * 60 * 60).to_i
    )
  }

  let (:issue2_started_date) {
    DateTime.new(2018, 4, 21, 9, 0, 0)
  }
  let (:issue2_finished_date) {
    DateTime.new(2018, 4, 23, 10, 0, 0)
  }
  let (:issue2) {
    OpenStruct.new(
      key: "XYZ-124",
      type: "Story",
      started: issue2_started_date,
      finished: issue2_finished_date,
      lead_time: ((issue2_finished_date - issue2_started_date) * 24 * 60 * 60).to_i
    )
  }

  let (:issue3_started_date) {
    DateTime.new(2018, 4, 21, 10, 0, 0)
  }
  let (:issue3_finished_date) {
    DateTime.new(2018, 4, 22, 14, 0, 0)
  }
  let (:issue3) {
    OpenStruct.new(
      key: "XYZ-125",
      type: "Story",
      started: issue3_started_date,
      finished: issue3_finished_date,
      lead_time: ((issue3_finished_date - issue3_started_date) * 24 * 60 * 60).to_i
    )
  }

  it "should be able to generate a report for one issue" do
    report = DailyReport.new([issue1])
    expected_report = [
      {
        date: "20180420",
        wip: 1,
        cumulative_finished_issues: 0,
        throughput: 0,
      },
      {
        date: "20180421",
        wip: 0,
        cumulative_finished_issues: 1,
        throughput: 1,
      },
    ]
    assert_equal(expected_report, report.perform)
  end

  it "should be able to generate a report for multiple issues" do
    report = DailyReport.new([issue2, issue3, issue1])
    expected_report = [
      {
        date: "20180420",
        wip: 1,
        cumulative_finished_issues: 0,
        throughput: 0,
      },
      {
        date: "20180421",
        wip: 2,
        cumulative_finished_issues: 1,
        throughput: 1,
      },
      {
        date: "20180422",
        wip: 1,
        cumulative_finished_issues: 2,
        throughput: 2,
      },
      {
        date: "20180423",
        wip: 0,
        cumulative_finished_issues: 3,
        throughput: 3,
      },
    ]
    assert_equal(expected_report, report.perform)
  end

  it "should not blow up when there is just one, unfinished issue" do
    issue_with_no_started_date = OpenStruct.new(
      key: "XYZ-1",
      type: "Story",
      started: issue1_started_date,
      finished: nil,
      lead_time: nil
    )
    report = DailyReport.new([issue_with_no_started_date])
    assert_equal([], report.perform)
  end

  it "should not blow up when there are unstarted issues" do
    issue_with_no_started_date = OpenStruct.new(
      key: "XYZ-1",
      type: "Story",
      started: nil,
      finished: nil,
      lead_time: nil
    )
    report = DailyReport.new([issue_with_no_started_date, issue1])
    expected_report = [
      {
        date: "20180420",
        wip: 1,
        cumulative_finished_issues: 0,
        throughput: 0,
      },
      {
        date: "20180421",
        wip: 0,
        cumulative_finished_issues: 1,
        throughput: 1,
      },
    ]
    # Same as the test for issue1, the other issue is ignored
    assert_equal(expected_report, report.perform)
  end

  describe "daily_report_point" do
    it "should set a consistent point on the same day no matter the input" do
      point1 = DailyReport.daily_report_point(issue1_started_date)
      point2 = DailyReport.daily_report_point(issue1_finished_date)
      assert_equal(point1.hour, point2.hour)
      assert_equal(point1.minute, point2.minute)
    end
  end
end