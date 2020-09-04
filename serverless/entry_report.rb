require "json"
require "digest"
require_relative "./lib/dates"
require_relative "./lib/jira"
require_relative "./lib/issue"
require_relative "./lib/cache"
require_relative "./lib/daily_report"
require_relative "./lib/issue_report"

def blank?(value)
  !value || value.empty?
end

def run(event:, context:)
  body = JSON.parse(event["body"])
  tenant_name = body["tenant_name"]
  username = body["username"]
  token = body["token"]
  return { statusCode: 401 } if blank?(tenant_name) || blank?(username) || blank?(token)

  jql = body["jql"]
  report = body["report"]
  return { statusCode: 400 } if blank?(jql) || blank?(report) || blank?(token)


  # The format of both dates is YYYY-MM-DD
  # https://developers.google.com/datastudio/connector/reference#getdata
  return { statusCode: 400 } if blank?(body["dateRange"]) || blank?(body["dateRange"]["startDate"]) || blank?(body["dateRange"]["endDate"])
  start_date = Dates.parse_google_date(body["dateRange"]["startDate"])
  end_date = Dates.parse_google_date(body["dateRange"]["endDate"])

  cache_key_hashpart = Digest::SHA2.hexdigest("#{username}\n#{token}\n#{jql}")
  cache_key = "#{tenant_name}-#{cache_key_hashpart}"
  cache = Cache.new(cache_key)

  if cache.hit?
    issues = cache.issues
  else
    jira = Jira.new(
      tenant_name: tenant_name,
      username: username,
      token: token,
    )
    jira.issue_search(jql)
  
    issues = jira.issues.map { |raw_issue| Issue.new(raw_issue) }

    cache.store(issues)
  end

  

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