class IntervalTree
  def initialize(interval_list)
    @center = (interval_list.flatten.sum)/(interval_list.length*2)
    left = interval_list.select { |i| i[1] < @center }
    right = interval_list.select { |i| i[0] > @center }
    @intersect = interval_list.select { |i| i[0] <= @center && @center <= i[1] }
    @left = IntervalTree.new(left) if left.length > 0
    @right = IntervalTree.new(right) if right.length > 0
  end

  def intersections_at_point(point)
    return left.intersections_at_point(point) if (point < @center && !@left.nil?)
    return right.intersections_at_point(point) if (point > @center && !@right.nil?)
    @intersect
      .select { |i| i[0] <= point && point <= i[1] }
      .length
  end
end