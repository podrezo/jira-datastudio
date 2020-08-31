class IntervalTree
  def initialize(interval_list)
    if interval_list.empty?
      @center = 0
      @intersect = []
      return
    end
    all_points = interval_list.flatten.compact
    @center = (all_points.sum)/(all_points.length)
    left = interval_list.select { |i| !i[1].nil? && i[1] < @center }
    right = interval_list.select { |i| i[0] > @center }
    @intersect = interval_list.select { |i| i[0] <= @center && (i[1].nil? || @center <= i[1]) }
    @left = IntervalTree.new(left) if left.length > 0
    @right = IntervalTree.new(right) if right.length > 0
  end

  def intersections_at_point(point)
    return @left.intersections_at_point(point) if (point < @center && !@left.nil?)
    return @right.intersections_at_point(point) if (point > @center && !@right.nil?)
    @intersect
      .select { |i| i[0] <= point && (i[1].nil? || point <= i[1]) }
      .length
  end
end