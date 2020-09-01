require "json"
require_relative "./lib/dates"
require_relative "./lib/jira"
require_relative "./lib/issue"
require_relative "./lib/daily_report"

def run(event:, context:)
  body = JSON.parse(event["body"])
  tenant_name = body["tenant_name"]
  username = body["username"]
  token = body["token"]
  jql = body["jql"]
  start_date = Dates.parse_google_date(body["dateRange"]["startDate"])
  end_date = Dates.parse_google_date(body["dateRange"]["endDate"])
  jira = Jira.new(
    tenant_name: tenant_name,
    username: username,
    token: token,
  )
  jira.issue_search(jql)
  
  # Optionally, a date range may be supplied
  # The format of both dates is YYYY-MM-DD
  # https://developers.google.com/datastudio/connector/reference#getdata
  report = DailyReport.new(
    jira.issues.map { |raw_issue| Issue.new(raw_issue) }
  )

  report_date_range = (Dates.end_of_day(start_date) .. Dates.end_of_day(end_date)).step(1)
  report.perform(report_date_range)
end