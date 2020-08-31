require_relative "../lib/interval_tree.rb"

describe "IntervalTree" do
  it "should not blow up for empty inputs" do
    interval_tree = IntervalTree.new([])
    assert_equal(0, interval_tree.intersections_at_point(0))
  end
  it "should have nothing before or after one interval" do
    interval_tree = IntervalTree.new([[5,10]])
    assert_equal(0, interval_tree.intersections_at_point(4))
    assert_equal(0, interval_tree.intersections_at_point(11))
  end
  it "should be able to count a lone interval" do
    interval_tree = IntervalTree.new([[5,10]])
    assert_equal(1, interval_tree.intersections_at_point(7))
  end
  it "should be able to count two overlapping intervals of the same size" do
    # -------------XXXXXXXXXX---------
    # -------------XXXXXXXXXX---------
    interval_tree = IntervalTree.new([[5,10], [5,10]])
    assert_equal(2, interval_tree.intersections_at_point(7))
    # boundary conditions
    assert_equal(2, interval_tree.intersections_at_point(5))
    assert_equal(2, interval_tree.intersections_at_point(10))
  end
  it "should be able to count two overlapping intervals of the same size but different times" do
    # -------------XXXXXXXXXX---------
    # ---------XXXXXXXXXX-------------
    interval_tree = IntervalTree.new([[2,7], [5,10]])
    assert_equal(2, interval_tree.intersections_at_point(6))
  end
  it "should be able to count two overlapping intervals where one envelops the other" do
    # -------------XXXXXXXXXX---------
    # ---------XXXXXXXXXXXXXXXXXX-----
    interval_tree = IntervalTree.new([[4,6], [4,9]])
    assert_equal(2, interval_tree.intersections_at_point(5))
  end
  it "should be able to handle a handful of intervals" do
    # -------------XXXXXXXXXX---------
    # ---------XXXXXXXXXXXXXXXXXX-----
    interval_tree = IntervalTree.new([
      [0,5],
      [1,9],
      [3,10],
      [4,6]
    ])
    assert_equal(2, interval_tree.intersections_at_point(1))
    assert_equal(2, interval_tree.intersections_at_point(2))
    assert_equal(4, interval_tree.intersections_at_point(5))
    assert_equal(2, interval_tree.intersections_at_point(9))
  end
  it "should work with the 'end' interval being nil, representing the future" do
    interval_tree = IntervalTree.new([[5,nil]])
    assert_equal(0, interval_tree.intersections_at_point(4))
    assert_equal(1, interval_tree.intersections_at_point(5))
    assert_equal(1, interval_tree.intersections_at_point(7))
    assert_equal(1, interval_tree.intersections_at_point(1000))
  end
end