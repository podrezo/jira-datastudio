require "uri"
require "net/http"
require "base64"
require "json"

class Jira
  def initialize(tenant_name:, username:, token:)
    @tenant_name = tenant_name
    @username = username
    @token = token
  end

  def issue_search(jql)
    url = URI("https://#{@tenant_name}.atlassian.net/rest/api/3/search")

    https = Net::HTTP.new(url.host, url.port);
    https.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request["Authorization"] = auth_value
    request["Content-Type"] = "application/json"
    body = {
      "expand": ["changelog"],
      "jql": jql,
      "maxResults" => 5,
      "fieldsByKeys" => false,
      "fields" => [
          "summary",
          "issuetype"
      ],
      "startAt" => 0
    }
    request.body = JSON.generate(body)

    response = https.request(request)
    JSON.parse(response.read_body)
  end

  private

  def auth_value
    creds = "#{@username}:#{@token}"
    b64creds = Base64.strict_encode64(creds)
    "Basic #{b64creds}"
  end
end