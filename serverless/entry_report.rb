require "json"
require_relative "./lib/dates"
require_relative "./lib/jira"
require_relative "./lib/issue"
require_relative "./lib/daily_report"
require_relative "./lib/issue_report"

def run(event:, context:)
  body = JSON.parse(event["body"])
  tenant_name = body["tenant_name"]
  username = body["username"]
  token = body["token"]
  jql = body["jql"]
  report = body["report"]
  # The format of both dates is YYYY-MM-DD
  # https://developers.google.com/datastudio/connector/reference#getdata
  start_date = Dates.parse_google_date(body["dateRange"]["startDate"])
  end_date = Dates.parse_google_date(body["dateRange"]["endDate"])
  jira = Jira.new(
    tenant_name: tenant_name,
    username: username,
    token: token,
  )
  jira.issue_search(jql)

  issues = jira.issues.map { |raw_issue| Issue.new(raw_issue) }

  case report
  when "issue"
    report = IssueReport.new(issues)
    report.perform(Dates.beginning_of_day(start_date), Dates.end_of_day(end_date))
  when "daily"
    report = DailyReport.new(issues)
    report_date_range = (Dates.end_of_day(start_date) .. Dates.end_of_day(end_date)).step(1)
    report.perform(report_date_range)
  else
    raise "Invalid report type '#{report}' supplied"
  end
end