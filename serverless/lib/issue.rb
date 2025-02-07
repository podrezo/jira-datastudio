require_relative "./dates"

JIRA_FIELD_NAME_STATUS = "status"
JIRA_STATUS_DEFAULT = "To Do"
JIRA_STATUS_DONE = "Done"

class Issue
  attr_reader :key, :type, :lead_time, :started, :finished
  def initialize(key, type, started, finished, lead_time)
    @key = key
    @type = type
    @started = started
    @finished = finished
    @lead_time = lead_time
  end

  def self.status_matrix(histories)
    histories
      .map do |history|
        datetime = history["created"]
        items = history["items"]
        items
          .select { |item| item["field"] == JIRA_FIELD_NAME_STATUS }
          .map do |item|
          {
            datetime: Dates.parse_jira_datetime(datetime),
            from:item["fromString"],
            to: item["toString"],
          }
        end
      end
      .flatten
      .sort { |logitem| logitem[:datetime] }
  end

  def self.from_jira_raw_json(issue)
    key = issue["key"]
    type = issue["fields"]["issuetype"]["name"]
    status_log = Issue.status_matrix(issue["changelog"]["histories"])
    started = status_log.first[:datetime] if(status_log.first&.fetch(:from) == JIRA_STATUS_DEFAULT)
    finished = status_log.last[:datetime] if(status_log.last&.fetch(:to) == JIRA_STATUS_DONE)
    if started.nil?
      lead_time = nil
    else
      lead_time = Dates.lead_time(started, finished || DateTime.now)
    end
    Issue.new(key, type, started, finished, lead_time)
  end
end