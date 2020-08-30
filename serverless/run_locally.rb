require "csv"
require_relative "./entry_report"

if ENV["JIRA_TENANT"].nil?
  puts "Please set JIRA_TENANT, JIRA_USERNAME, JIRA_TOKEN, JIRA_JQL env vars"
  exit
end

event = {
  "verbose" => false,
  "tenant_name" => ENV["JIRA_TENANT"],
  "username" => ENV["JIRA_USERNAME"],
  "token" => ENV["JIRA_TOKEN"],
  "jql" => ENV["JIRA_JQL"],
}

report_results = run(event: event, context: nil)


csv_string = CSV.generate do |csv|
  csv << ["Date", "WIP", "Cumulative Finished Issues", "Throughput (7d)"]
  report_results.each do |daily_stats|
    csv << [
      daily_stats[:date],
      daily_stats[:wip],
      daily_stats[:cumulative_finished_issues],
      daily_stats[:throughput]
    ]
  end
end

puts csv_string