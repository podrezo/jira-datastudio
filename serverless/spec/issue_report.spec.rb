require "ostruct"
require_relative "../lib/issue_report.rb"

def test_day(day)
  DateTime.new(2018, 4, day)
end

describe "IssueReport" do
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

  it "should be able to generate a report for multiple issues" do
    report = IssueReport.new([issue2, issue3, issue1])
    start_date = DateTime.new(2018,4,20)
    end_date = DateTime.new(2018,4,23)
    expected_report = [
      {
        date: Dates.format_as_datastudio_ymd(issue1.finished),
        lead_time: issue1.lead_time.to_s,
        key: issue1.key,
        type: issue1.type,
      },
      {
        date: Dates.format_as_datastudio_ymd(issue2.finished),
        lead_time: issue2.lead_time.to_s,
        key: issue2.key,
        type: issue2.type,
      },
      {
        date: Dates.format_as_datastudio_ymd(issue3.finished),
        lead_time: issue3.lead_time.to_s,
        key: issue3.key,
        type: issue3.type,
      },
    ]
    assert_matched_arrays(expected_report, report.perform(Dates.beginning_of_day(test_day(20)), Dates.end_of_day(test_day(23))))
  end

  it "should work when there are no issues" do
    report = IssueReport.new([])
    start_date = DateTime.new(2018,4,20)
    end_date = DateTime.new(2018,4,23)
    expected_report = []
    assert_matched_arrays(expected_report, report.perform(Dates.beginning_of_day(test_day(20)), Dates.end_of_day(test_day(23))))
  end

  it "should only show issues finished within the period specified" do
    report = IssueReport.new([issue2, issue3, issue1])
    start_date = DateTime.new(2018,4,20)
    end_date = DateTime.new(2018,4,23)
    expected_report = [
      {
        date: Dates.format_as_datastudio_ymd(issue3.finished),
        lead_time: issue3.lead_time.to_s,
        key: issue3.key,
        type: issue3.type,
      },
    ]
    assert_matched_arrays(expected_report, report.perform(Dates.beginning_of_day(test_day(22)), Dates.end_of_day(test_day(22))))
  end
end