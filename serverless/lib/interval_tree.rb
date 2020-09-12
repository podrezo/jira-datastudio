class IntervalTree
  def initialize(interval_list)
    if interval_list.empty?
      @center = 0
      @intersect = []
      return
    end
    # Check for invalid ranges; only check the first element to avoid iterating over the entire array
    # If the element that is invalid is further down, we will eventually recurse down to it
    # This avoids having to do an extra pass over the entire array every time
    if !interval_list.first[1].nil? && interval_list.first[0] > interval_list.first[1]
      raise "Invalid range specified #{interval_list.first[0]} --> #{interval_list.first[1]}"
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