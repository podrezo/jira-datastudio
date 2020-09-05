require "ostruct"
require "timecop"
require_relative "../lib/daily_report.rb"

def test_date_range(day_from, day_to)
  from = DateTime.new(2018, 4, day_from, 23, 59, 59)
  to = DateTime.new(2018, 4, day_to, 23, 59, 59)
  (from..to).step(1)
end

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

  it "should work for input dates that have no issues (before)" do
    report = DailyReport.new([])
    expected_report = []
    assert_matched_arrays(expected_report, report.perform(test_date_range(20, 22)))
  end

  it "should work for input dates that have no issues (after)" do
    report = DailyReport.new([issue1])
    expected_report = [
      {
        date: "20180424",
        wip: 0,
        cumulative_finished_issues: 1,
        throughput_week: 1,
        type: "Story",
      },
      {
        date: "20180425",
        wip: 0,
        cumulative_finished_issues: 1,
        throughput_week: 1,
        type: "Story",
      },
    ]
    assert_matched_arrays(expected_report, report.perform(test_date_range(24, 25)))
  end
  
  it "should not produce any data points for a time that is in the future" do
    report = DailyReport.new([issue1])
    expected_report = [
      {
        date: "20180424",
        wip: 0,
        cumulative_finished_issues: 1,
        throughput_week: 1,
        type: "Story",
      },
    ]
    Timecop.freeze(DateTime.new(2018, 4, 25, 11, 30)) do
      assert_matched_arrays(expected_report, report.perform(test_date_range(24, 30)))
    end
  end

  it "should be able to generate a report for one issue" do
    report = DailyReport.new([issue1])
    start_date = DateTime.new(2018,4,20)
    end_date = DateTime.new(2018,4,21)
    expected_report = [
      {
        date: "20180420",
        wip: 1,
        cumulative_finished_issues: 0,
        throughput_week: 0,
        type: "Story",
      },
      {
        date: "20180421",
        wip: 0,
        cumulative_finished_issues: 1,
        throughput_week: 1,
        type: "Story",
      },
    ]
    assert_matched_arrays(expected_report, report.perform(test_date_range(20, 21)))
  end

  it "should distinguish between issue types" do
    other_type_issue = OpenStruct.new(
      key: "XYZ-124",
      type: "Task",
      started: issue1_started_date,
      finished: issue1_finished_date,
      lead_time: ((issue1_finished_date - issue1_started_date) * 24 * 60 * 60).to_i
    )
    report = DailyReport.new([other_type_issue, issue1])
    start_date = DateTime.new(2018,4,20)
    end_date = DateTime.new(2018,4,21)
    expected_report = [
      {
        date: "20180420",
        wip: 1,
        cumulative_finished_issues: 0,
        throughput_week: 0,
        type: "Story",
      },
      {
        date: "20180420",
        wip: 1,
        cumulative_finished_issues: 0,
        throughput_week: 0,
        type: "Task",
      },
      {
        date: "20180421",
        wip: 0,
        cumulative_finished_issues: 1,
        throughput_week: 1,
        type: "Story",
      },
      {
        date: "20180421",
        wip: 0,
        cumulative_finished_issues: 1,
        throughput_week: 1,
        type: "Task",
      },
    ]
    assert_matched_arrays(expected_report, report.perform(test_date_range(20, 21)))
  end

  it "should be able to generate a report for multiple issues" do
    report = DailyReport.new([issue2, issue3, issue1])
    start_date = DateTime.new(2018,4,20)
    end_date = DateTime.new(2018,4,23)
    expected_report = [
      {
        date: "20180420",
        wip: 1,
        cumulative_finished_issues: 0,
        throughput_week: 0,
        type: "Story",
      },
      {
        date: "20180421",
        wip: 2,
        cumulative_finished_issues: 1,
        throughput_week: 1,
        type: "Story",
      },
      {
        date: "20180422",
        wip: 1,
        cumulative_finished_issues: 2,
        throughput_week: 2,
        type: "Story",
      },
      {
        date: "20180423",
        wip: 0,
        cumulative_finished_issues: 3,
        throughput_week: 3,
        type: "Story",
      },
    ]
    assert_matched_arrays(expected_report, report.perform(test_date_range(20, 23)))
  end

  it "should be able to filter dates of interest when performing the report" do
    report = DailyReport.new([issue2, issue3, issue1])
    start_date = DateTime.new(2018,4,21)
    end_date = DateTime.new(2018,4,22)
    expected_report = [
      {
        date: "20180421",
        wip: 2,
        cumulative_finished_issues: 1,
        throughput_week: 1,
        type: "Story",
      },
      {
        date: "20180422",
        wip: 1,
        cumulative_finished_issues: 2,
        throughput_week: 2,
        type: "Story",
      },
    ]
    assert_matched_arrays(expected_report, report.perform(test_date_range(21, 22)))
  end

  it "should count unfinished issues for WIP" do
    unfinished_issue = OpenStruct.new(
      key: "XYZ-125",
      type: "Story",
      started: DateTime.new(2018, 4, 20, 11, 25),
      finished: nil,
      lead_time: nil
    )
    start_date = DateTime.new(2018,4,20)
    end_date = DateTime.new(2018,4,21)
    report = DailyReport.new([unfinished_issue, issue1])
    expected_report = [
      {
        date: "20180420",
        wip: 2,
        cumulative_finished_issues: 0,
        throughput_week: 0,
        type: "Story",
      },
      {
        date: "20180421",
        wip: 1,
        cumulative_finished_issues: 1,
        throughput_week: 1,
        type: "Story",
      },
    ]
    assert_matched_arrays(expected_report, report.perform(test_date_range(20, 21)))
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
    start_date = DateTime.new(2018,4,20)
    end_date = DateTime.new(2018,4,20)
    assert_matched_arrays([
      {
        date: "20180420",
        wip: 1,
        cumulative_finished_issues: 0,
        throughput_week: 0,
        type: "Story",
      }
    ], report.perform(test_date_range(20, 20)))
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
    start_date = DateTime.new(2018,4,20)
    end_date = DateTime.new(2018,4,21)
    expected_report = [
      {
        date: "20180420",
        wip: 1,
        cumulative_finished_issues: 0,
        throughput_week: 0,
        type: "Story",
      },
      {
        date: "20180421",
        wip: 0,
        cumulative_finished_issues: 1,
        throughput_week: 1,
        type: "Story",
      },
    ]
    # Same as the test for issue1, the other issue is ignored
    assert_matched_arrays(expected_report, report.perform(test_date_range(20, 21)))
  end
end