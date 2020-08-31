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

  if(body["dateRange"] && body["dateRange"]["startDate"] && body["dateRange"]["endDate"])
    start_date = Dates.parse_google_date(body["dateRange"]["startDate"])
    end_date = Dates.parse_google_date(body["dateRange"]["endDate"])
    data = report.perform(start_date, end_date)
  else
    data = report.perform
  end

  data
end