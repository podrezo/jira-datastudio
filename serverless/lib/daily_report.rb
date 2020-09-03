require_relative "./interval_tree"

class DailyReport
  def initialize(issues)
    issues_by_type = issues.group_by { |issue| issue.type }
    @all_reports = issues_by_type.map do |type, issues|
      DailyReportSingleType.new(issues, type)
    end
  end

  def perform(range)
    @all_reports.map { |report| report.perform(range) }.flatten
  end
end

class DailyReportSingleType
  def initialize(issues, type)
    @type = type
    @issues_sorted_by_started = issues
      .select { |issue| !issue.started.nil? }
      .sort { |issue| issue.started }
    @issues_sorted_by_finished = @issues_sorted_by_started
      .select { |issue| !issue.finished.nil? }
      .sort { |issue| issue.finished }
    intervals = @issues_sorted_by_started.map { |issue| [issue.started.strftime("%s").to_i, issue.finished&.strftime("%s")&.to_i] }
    @interval_tree = IntervalTree.new(intervals)
  end

  def perform(range)
    # The "-1" is because we only want to count the ones that were finished BEFORE this date
    # That way, we can count the ones completed on this day separately
    cumulative_finished_issues = issues_completed_within_range(DateTime.new(0), range.first - 1)
    range.to_a
      .map do |point|
        issues_finished_this_day = issues_completed_within_range(point - 1, point)
        cumulative_finished_issues += issues_finished_this_day
        {
          date: Dates.format_as_google_ymd(point),
          wip: @interval_tree.intersections_at_point(point.strftime("%s").to_i),
          cumulative_finished_issues: cumulative_finished_issues,
          throughput_week: issues_completed_within_range(point - 7, point),
          type: @type
        }
      end
  end

  private

  def issues_completed_within_range(from, to)
    @issues_sorted_by_finished
      .select { |issue| from < issue.finished && issue.finished < to }
      .length
  end
end