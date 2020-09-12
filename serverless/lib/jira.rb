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
    # As per Jira's docs, set the requested number of records really high
    # If the actual maximum specified for the API is lower than that, it will
    # return the lower number which we will then adjust into this variable
    @max_results = 1000
    @issues = nil
  end

  def issue_search(jql)
    @issues = []
    first_page = issue_search_page(jql, 0)
    @issues += first_page["issues"]
    total_records = first_page["total"]
    puts "Query '#{jql}' ==> #{total_records} total records"

    threads = (@issues.length .. total_records).step(@max_results).to_a.map do |start_at|
      Thread.new do
        Thread.current[:issues_subset] = issue_search_page(jql, start_at)["issues"]
      end
    end

    threads.each do |thread|
      @issues += thread.join[:issues_subset]
    end

    puts "Total records pulled: #{@issues.length}. Threads used: #{threads.length}"
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
      "maxResults" => @max_results,
      "fieldsByKeys" => false,
      "fields" => [
          "summary",
          "issuetype"
      ],
      "startAt" => start_at
    }
    request.body = JSON.generate(body)

    response = https.request(request)
    data = JSON.parse(response.read_body)
    @max_results = data["maxResults"]
    data
  end
end