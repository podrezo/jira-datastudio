require "uri"
require "net/http"
require "base64"
require "json"

class Jira
  attr_reader :issues

  def initialize(tenant_name:, username:, token:)
    @tenant_name = tenant_name
    @username = username
    @token = token
    @issues = []
  end

  def issue_search(jql)
    page_number = 1
    result = {
      "total" => 1 # Assume there's at least one result, this will be overwritten 
    }
    while(@issues.length < result["total"]) do
      result = issue_search_page(jql, @issues.length)
      @issues += result["issues"]
      puts "[#{@tenant_name}] Page #{page_number}: Fetched #{result["issues"].length} issues"
      page_number += 1
    end
    puts "[#{@tenant_name}] Finished fetching all issues: #{@issues.length} issues total"
  end

  private

  def auth_value
    creds = "#{@username}:#{@token}"
    b64creds = Base64.strict_encode64(creds)
    "Basic #{b64creds}"
  end

  def issue_search_page(jql, start_at = 0)
    url = URI("https://#{@tenant_name}.atlassian.net/rest/api/3/search")

    https = Net::HTTP.new(url.host, url.port);
    https.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request["Authorization"] = auth_value
    request["Content-Type"] = "application/json"
    body = {
      "expand": ["changelog"],
      "jql": jql,
      "maxResults" => 100,
      "fieldsByKeys" => false,
      "fields" => [
          "summary",
          "issuetype"
      ],
      "startAt" => start_at
    }
    request.body = JSON.generate(body)

    response = https.request(request)
    JSON.parse(response.read_body)
  end
end