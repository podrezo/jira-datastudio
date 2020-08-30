require "json"
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
  
  report = DailyReport.new(
    jira.issues.map { |raw_issue| Issue.new(raw_issue) }
  )
  data = report.perform

  data
end