require 'hako.rb'

require 'minitest/autorun'

class TestVector < MiniTest::Test
  def test_initialize
    v = Vector.new(4)
    assert_equal 'Vector[0.0,0.0,0.0,0.0]', v.inspect
    assert_equal 'Vector[0.0,0.0,0.0,0.0]', v.to_s
    v[0] = 1.0
    assert_equal 1.0, v[0]
    v[1] = 2.0
    v[2] = 3.0
    v[-1] = 4.0
    assert_equal 4.0, v[-1]
    assert_equal [1.0,2.0,3.0,4.0].to_vector, v
    assert_equal v, [1.0,2.0,3.0,4.0].to_vector
    assert_equal v, Vector[1.0,2.0,3.0,4.0]
    v2 = v.copy
    v[0] = 5.0
    assert_equal 1.0, v2[0]
    v2[0] = 6.0
    assert_equal 5.0, v[0]
  end
  def test_resize
    v = Vector[1.0,2.0]
    assert_equal Vector[1.0,2.0,0.0,0.0,0.0], v.resize(5)
    assert_equal Vector[1.0,2.0], v.resize(2)
    assert_equal Vector[1.0], v.resize(1)
    assert_equal Vector[1.0,2.0,1.0,1.0,1.0], v.resize(5, 1.0)
    assert_equal Vector[1.0,2.0], v.resize(2, 1.0)
    assert_equal Vector[1.0], v.resize(1, 1.0)
    assert_equal Vector[1.0,2.0], v
  end
  def test_unops
    v = Vector[1.0,2.0,3.0,4.0]
    assert_equal Vector[1.0,2.0,3.0,4.0], +v
    assert_equal Vector[-1.0,-2.0,-3.0,-4.0], -v
    assert_equal Vector[1.0,2.0,3.0,4.0], v
  end
  def test_binops
    v1 = Vector[1.0,2.0,3.0,4.0]
    v2 = Vector[4.0,3.0,2.0,1.0]
    v3 = Vector[1.0,2.0,3.0,0.0]
    assert_equal Vector[2.0,3.0,4.0,5.0], v1 + 1.0
    assert_equal Vector[2.0,3.0,4.0,5.0], 1.0 + v1
    assert_equal Vector[5.0,5.0,5.0,5.0], v1 + v2
    assert_equal Vector[0.0,1.0,2.0,3.0], v1 - 1.0
    assert_equal Vector[0.0,-1.0,-2.0,-3.0], 1.0 - v1
    assert_equal Vector[-3.0,-1.0,1.0,3.0], v1 - v2
    assert_equal Vector[2.0,4.0,6.0,8.0], v1 * 2.0
    assert_equal Vector[2.0,4.0,6.0,8.0], 2.0 * v1
    assert_equal Vector[4.0,6.0,6.0,4.0], v1.hadamard(v2)
    assert_equal Vector[1.0,4.0,9.0,16.0], v1.power_elements(2)
    assert_equal Vector[1.0,1.0/2.0,1.0/3.0,Float::NAN], v3.power_elements(-1)
    assert_equal Vector[1.0,1.0/2.0,1.0/3.0,0.0], v3.power_elements(-1, 0.0)
    assert_equal Vector[0.5,1.0,1.5,2.0], v1 / 2.0
    assert_equal Vector[2.0,1.0,2.0/3.0,0.5], 2.0 / v1
    assert_equal 20, v1.dot(v2)
    assert_equal Vector[1.0,2.0,3.0,4.0], v1
    assert_equal Vector[-1.0,-2.0,-3.0,-4.0], -v1
  end
  def test_min_max
    assert_equal 2.0, Vector[1.0,2.0,-2.0,1.0].max
    assert_equal (-2.0), Vector[1.0,2.0,-2.0,1.0].min
    assert_equal 'NaN', Vector[].max.to_s
    assert_equal 'NaN', Vector[].min.to_s
  end
  def test_norm
    assert_equal 6.0, Vector[1.0,-2.0,3.0].l1norm
    assert_equal 14.0**0.5, Vector[1.0,-2.0,3.0].l2norm
  end
  def test_rank1op
    v = Vector[1.0,2.0]
    w = Vector[3.0,4.0,5.0]
    assert_equal Matrix[[3.0,4.0,5.0],[6.0,8.0,10.0]], v.rank1op(w)
  end
  def test_round
    v = Vector[1.0,2.00001,3.000002]
    assert_equal Vector[1.0,2.00001,3.0], v.round(5)
    assert_equal Vector[1.0,2.00001,3.000002], v
  end
  def test_sum
    assert_equal 2.0, Vector[1.0,-2.0,3.0].sum
  end
end
