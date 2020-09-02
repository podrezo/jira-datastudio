require_relative "./interval_tree"

class IssueReport
  def initialize(issues)
    @issues = issues
  end

  def perform(report_begin_datetime, report_end_datetime)
    @issues.filter_map do |issue|
      next(nil) if issue.finished.nil? || issue.finished < report_begin_datetime || issue.finished > report_end_datetime
      {
        date: Dates.format_as_google_ymd(issue.finished),
        lead_time: issue.lead_time,
        key: issue.key,
        type: issue.type
      }
    end
  end
end
