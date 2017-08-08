require 'hako.rb'

require 'minitest/autorun'

class TestSortedSet < MiniTest::Test
  def test_invert
    set = SortedSet.new
    assert_equal({}, set.invert)
    set << :c
    set << :z
    set << :a
    assert_equal({:a => 0, :c => 1, :z => 2}, set.invert)
    set.delete(:c)
    assert_equal({:a => 0, :z => 1}, set.invert)
    set << :d
    assert_equal({:a => 0, :d => 1, :z => 2}, set.invert)
  end
end
