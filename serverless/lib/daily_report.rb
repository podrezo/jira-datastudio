require_relative "./interval_tree"

class DailyReport
  def initialize(issues)
    @issues = issues
    intervals = @issues.map { |issue| [issue.started.strftime("%s").to_i, issue.finished.strftime("%s").to_i] }
    @interval_tree = IntervalTree.new(intervals)
  end

  def perform
    timeline.to_a
      .map do |point|
        {
          date: point.strftime("%Y%m%d"),
          wip: @interval_tree.intersections_at_point(point.strftime("%s").to_i),
          cumulative_finished_issues: 0
        }
      end
  end

  def timeline
    issues_sorted_by_started = @issues.sort { |issue| issue.started }
    issues_sorted_by_finished = @issues.sort { |issue| issue.finished }
    earliest_date = DailyReport.daily_report_point(issues_sorted_by_started.first.started)
    latest_date = DailyReport.daily_report_point([
      issues_sorted_by_started.last.started,
      issues_sorted_by_finished.last.finished,
    ].max)
    # Step by one day
    (earliest_date..latest_date).step(1)
  end

  def self.daily_report_point(datetime)
    DateTime.new(datetime.year, datetime.month, datetime.day, 23, 59, 59)
  end
end