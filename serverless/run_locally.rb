require "csv"
require "json"
require_relative "./entry_report"

if ENV["JIRA_TENANT"].nil?
  puts "Please set JIRA_TENANT, JIRA_USERNAME, JIRA_TOKEN, JIRA_JQL env vars"
  exit
end

body = {
  "tenant_name" => ENV["JIRA_TENANT"],
  "username" => ENV["JIRA_USERNAME"],
  "token" => ENV["JIRA_TOKEN"],
  "jql" => ENV["JIRA_JQL"],
  "dateRange" => {
    "startDate" => "2020-08-01",
    "endDate" => "2020-08-31"
  },
  "report" => "issue",
  "disable_caching" => true,
}


event = {
  "body" => JSON.generate(body)
}

report_results = run(event: event, context: nil)

# all_fields = report_results.first.keys

# csv_string = CSV.generate do |csv|
#   csv << all_fields.map(&:to_s)
#   report_results.each do |row_values|
#     csv << all_fields.map { |k| row_values[k] }
#   end
# end

# puts csv_string

puts report_results.length