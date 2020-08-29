require_relative "./interval_tree"

class DailyReport
  def initialize(issues)
    issues_with_dates = issues.select { |issue| !issue.started.nil? && !issue.finished.nil? }
    @issues_sorted_by_started = issues_with_dates.sort { |issue| issue.started }
    @issues_sorted_by_finished = issues_with_dates.sort { |issue| issue.finished }
    intervals = issues_with_dates.map { |issue| [issue.started.strftime("%s").to_i, issue.finished.strftime("%s").to_i] }
    @interval_tree = IntervalTree.new(intervals)
  end

  def perform
    return [] if @issues_sorted_by_started.empty?
    cumulative_finished_issues = 0
    timeline.to_a
      .map do |point|
        issues_finished_this_day = issues_completed_within_range(point - 1, point)
        cumulative_finished_issues += issues_finished_this_day
        {
          date: point.strftime("%Y%m%d"),
          wip: @interval_tree.intersections_at_point(point.strftime("%s").to_i),
          cumulative_finished_issues: cumulative_finished_issues,
          throughput: issues_completed_within_range(point - 7, point)
        }
      end
  end

  def timeline
    earliest_date = DailyReport.daily_report_point(@issues_sorted_by_started.first.started)
    latest_date = DailyReport.daily_report_point([
      @issues_sorted_by_started.last.started,
      @issues_sorted_by_finished.last.finished,
    ].max)
    # Step by one day
    (earliest_date..latest_date).step(1)
  end

  def self.daily_report_point(datetime)
    DateTime.new(datetime.year, datetime.month, datetime.day, 23, 59, 59)
  end

  private

  def issues_completed_within_range(from, to)
    @issues_sorted_by_finished
      .select { |issue| from < issue.finished && issue.finished < to}
      .length
  end
end