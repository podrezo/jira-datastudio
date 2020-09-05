require "json"
require_relative "../lib/issue.rb"
require_relative "../lib/issue_cache.rb"

describe "IssueCache" do
  it "should be able to convert an issue to a hash and then convert it back" do

    issue = Issue.new("ABC-42", "Story", DateTime.new(2020, 8, 27, 11, 50), DateTime.new(2020, 8, 27, 12, 0), 600)

    issue_hash = IssueCache.issue_to_hash(issue)
    assert_equal({
      "k" => "ABC-42",
      "t" => "Story",
      "s" => "2020-08-27",
      "f" => "2020-08-27",
      "l" => 600,
    }, issue_hash)

    issue_copy = IssueCache.issue_from_hash(issue_hash)

    assert_equal(issue.key, issue_copy.key)
    assert_equal(issue.type, issue_copy.type)
    assert_equal(DateTime.new(2020, 8, 27), issue_copy.started) # Everything past YMD is ignored
    assert_equal(DateTime.new(2020, 8, 27), issue_copy.finished) # Everything past YMD is ignored
    assert_equal(issue.lead_time, issue_copy.lead_time)
  end
  describe "issue_to_hash" do
    it "should be able to convert nil dates" do

      issue = Issue.new("ABC-42", "Story", nil, nil, nil)
  
      issue_hash = IssueCache.issue_to_hash(issue)
      assert_equal({
        "k" => "ABC-42",
        "t" => "Story",
        "s" => nil,
        "f" => nil,
        "l" => nil,
      }, issue_hash)
    end
  end
end