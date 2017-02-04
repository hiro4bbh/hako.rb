require 'hako.rb'

require 'minitest/autorun'

class TestMatrix < MiniTest::Test
  def test_initialize
    _A = Matrix.new(3, 3)
    assert_equal 'Matrix[[0.0,0.0,0.0],[0.0,0.0,0.0],[0.0,0.0,0.0]]', _A.inspect
    assert_equal 'Matrix[[0.0,0.0,0.0],[0.0,0.0,0.0],[0.0,0.0,0.0]]', _A.to_s
    assert_equal [[0.0,0.0,0.0],[0.0,0.0,0.0],[0.0,0.0,0.0]], _A.to_a
    _A[0,0] = 1.0
    assert_equal 1.0, _A[0,0]
    _A[-1,0] = 2.0
    assert_equal 2.0, _A[-1,0]
    _A[0,-1] = 3.0
    assert_equal 3.0, _A[0,-1]
    assert_equal _A, [[1.0,0.0,3.0],[0.0,0.0,0.0],[2.0,0.0,0.0]].to_matrix
    assert_equal _A, Vector[1.0,0.0,2.0,0.0,0.0,0.0,3.0,0.0,0.0].to_matrix(3,3)
    _B = _A.copy
    _B[0,0] = 4.0
    assert_equal 1.0, _A[0,0]
    _A[0,0] = 5.0
    assert_equal 4.0, _B[0,0]
    assert_equal Matrix[[1.0,0.0,0.0],[0.0,2.0,0.0],[0.0,0.0,3.0]], Matrix::diag(Vector[1.0,2.0,3.0])
    assert_equal Matrix[[1.0,0.0,0.0],[0.0,1.0,0.0],[0.0,0.0,1.0]], Matrix::I(3)
  end
  def test_resize
    _A = Matrix[[1.0,2.0],[3.0,4.0]]
    assert_equal Matrix[[1.0,2.0],[3.0,4.0],[0.0,0.0]], _A.resize(3, 2)
    assert_equal Matrix[[1.0,2.0,0.0],[3.0,4.0,0.0]], _A.resize(2, 3)
    assert_equal Matrix[[1.0],[3.0]], _A.resize(2, 1)
    assert_equal Matrix[[1.0,2.0]], _A.resize(1, 2)
    assert_equal Matrix[[1.0,2.0],[3.0,4.0]], _A
  end
  def test_unops
    _A = Matrix[[1.0,2.0],[3.0,4.0]]
    assert_equal Matrix[[1.0,2.0],[3.0,4.0]], +_A
    assert_equal Matrix[[-1.0,-2.0],[-3.0,-4.0]], -_A
    assert_equal Matrix[[1.0,2.0],[3.0,4.0]], _A
    assert_equal Matrix[[1.0,3.0],[2.0,4.0]], _A.t
  end
  def test_binops
    _A = Matrix[[1.0,2.0],[3.0,4.0]]
    _B = Matrix[[4.0,3.0],[2.0,1.0]]
    _C = Matrix[[1.0,2.0,3.0],[4.0,5.0,6.0]]
    v = Vector[1.0,2.0]
    assert_equal Matrix[[2.0,3.0],[4.0,5.0]], _A + 1.0
    assert_equal Matrix[[2.0,3.0],[4.0,5.0]], 1.0 + _A
    assert_equal Matrix[[5.0,5.0],[5.0,5.0]], _A + _B
    assert_equal Matrix[[0.0,1.0],[2.0,3.0]], _A - 1.0
    assert_equal Matrix[[0.0,-1.0],[-2.0,-3.0]], 1.0 - _A
    assert_equal Matrix[[-3.0,-1.0],[1.0,3.0]], _A - _B
    assert_equal Matrix[[2.0,4.0],[6.0,8.0]], _A * 2.0
    assert_equal Matrix[[2.0,4.0],[6.0,8.0]], 2.0 * _A
    assert_equal Matrix[[8.0,5.0],[20.0,13.0]], _A * _B
    assert_equal Vector[9.0,12.0,15.0], v * _C
    assert_equal Matrix[[8.0],[18.0]], _A*Vector[2.0,3.0]
    assert_equal Matrix[[4.0,6.0],[6.0,4.0]], _A.hadamard(_B)
    assert_equal Matrix[[2.0,4.0],[9.0,12.0]], _A.mul_rows(Vector[2.0,3.0])
    assert_equal Matrix[[1.0,4.0],[9.0,16.0]], _A.power_elements(2)
    assert_equal Matrix[[0.5,1.0],[1.5,2.0]], _A / 2.0
    assert_equal Matrix[[2.0,1.0],[2.0/3.0,0.5]], 2.0 / _A
    assert_equal Matrix[[1.0,2.0],[3.0,4.0]], _A
    assert_equal Matrix[[4.0,3.0],[2.0,1.0]], _B
  end
  def test_select_project
    _A = Matrix[[1.0,2.0,3.0],[4.0,5.0,6.0]]
    assert_equal Matrix[[1.0,2.0,3.0],[4.0,5.0,6.0]], _A.project(:*)
    assert_equal Matrix[[1.0,2.0,3.0],[4.0,5.0,6.0]], _A.project([0,1,2])
    assert_equal Matrix[[2.0,3.0,1.0],[5.0,6.0,4.0]], _A.project(1,2,0)
    assert_equal Matrix[[2.0,3.0],[5.0,6.0]], _A.project(1,2)
    assert_equal Matrix[[2.0,3.0,1.0,3.0],[5.0,6.0,4.0,6.0]], _A.project(1,2,0,2)
    assert_equal Matrix[[1.0,2.0],[4.0,5.0]], _A.project(0..-2)
    assert_equal Matrix[[1.0,2.0,3.0],[4.0,5.0,6.0]], _A.select([0,1])
    assert_equal Matrix[[4.0,5.0,6.0],[1.0,2.0,3.0],[4.0,5.0,6.0]], _A.select([1,0,1])
  end
  def test_diag
    _A = Matrix[[1.0,2.0],[3.0,4.0]]
    _B = Matrix[[1.0,2.0,3.0],[4.0,5.0,6.0]]
    _C = Matrix[[1.0,2.0],[3.0,4.0],[5.0,6.0]]
    assert_equal Vector[1.0,4.0], _A.diag
    assert_equal Vector[1.0,5.0], _B.diag
    assert_equal Vector[1.0,4.0], _C.diag
  end
  def test_min_max
    assert_equal 2.0, Matrix[[1.0,2.0],[-1.0,2.0]].max
    assert_equal (-1.0), Matrix[[1.0,2.0],[-1.0,2.0]].min
  end
  def test_round
    _A = Matrix[[1.0,2.00001],[3.000002,4.000007]]
    assert_equal Matrix[[1.0,2.00001],[3.0,4.00001]], _A.round(5)
    assert_equal Matrix[[1.0,2.00001],[3.000002,4.000007]], _A
  end
  def test_sums
    _A = Matrix[[1.0,2.0,3.0],[4.0,5.0,6.0]]
    assert_equal Vector[5.0,7.0,9.0], _A.colsums
    assert_equal Vector[6.0,15.0], _A.rowsums
  end
end
