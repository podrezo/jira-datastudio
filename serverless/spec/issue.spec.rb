require_relative "../lib/issue.rb"
require "json"

describe "Issue" do
  it "should be able to process an issue and get the relevant fields" do
    issue_json = <<-JSON
      {
        "expand": "operations,versionedRepresentations,editmeta,changelog,renderedFields",
        "id": "36129",
        "self": "https://somecompany.atlassian.net/rest/api/3/issue/36129",
        "key": "ABC-42",
        "changelog": {
          "startAt": 0,
          "maxResults": 11,
          "total": 11,
          "histories": [
            {
              "id": "345904",
              "created": "2020-08-27T16:45:56.842-0400",
              "items": [
                {
                  "field": "status",
                  "fieldtype": "jira",
                  "fieldId": "status",
                  "from": "10137",
                  "fromString": "In Progress",
                  "to": "10001",
                  "toString": "Done"
                }
              ]
            },
            {
              "id": "345736",
              "created": "2020-08-27T11:23:36.012-0400",
              "items": [
                {
                  "field": "status",
                  "fieldtype": "jira",
                  "fieldId": "status",
                  "from": "10000",
                  "fromString": "To Do",
                  "to": "10006",
                  "toString": "In Progress"
                }
              ]
            }
          ]
        },
        "fields": {
          "issuetype": {
            "self": "https://somecompany.atlassian.net/rest/api/3/issuetype/10001",
            "id": "10001",
            "name": "Story",
            "subtask": false,
            "avatarId": 10315
          }
        }
      }
    JSON
    issue = Issue.new(JSON.parse(issue_json))
    assert_equal("ABC-42", issue.key)
    assert_equal("Story", issue.type)
    assert_equal("2020-08-27T11:23:36+00:00", issue.started.to_s)
    assert_equal("2020-08-27T16:45:56+00:00", issue.finished.to_s)
    assert_equal(19340, issue.lead_time)
  end
  describe "status_matrix" do
    it "ignores non-status history items" do
      histories_json = <<-JSON
        [
          {
            "id": "345904",
            "created": "2020-08-27T16:45:56.842-0400",
            "items": [
              {
                "field": "notstatus",
                "fieldtype": "jira",
                "fieldId": "status",
                "from": "10137",
                "fromString": "In Progress",
                "to": "10001",
                "toString": "Done"
              }
            ]
          },
          {
            "id": "345736",
            "created": "2020-08-27T11:23:36.012-0400",
            "items": [
              {
                "field": "notstatus",
                "fieldtype": "jira",
                "fieldId": "status",
                "from": "10000",
                "fromString": "To Do",
                "to": "10006",
                "toString": "In Progress"
              }
            ]
          }
        ]
      JSON
      
      assert_equal([], Issue.status_matrix(JSON.parse(histories_json)))
    end
  end
end