require 'hako'

require 'minitest/autorun'

class TestMath < MiniTest::Test
  def test_sign
    assert_equal Vector[10,30,20,30,20,10], sign(Vector[1.0,-1.0,0.0,-1.0,0.0,1.0], 10, 20, 30)
    assert_equal Vector[1.0,14.0,9.0,16.0,11.0,6.0], sign(Vector[1.0,-1.0,0.0,-1.0,0.0,1.0], Vector[1.0,2.0,3.0,4.0,5.0,6.0], Vector[7.0,8.0,9.0,10.0,11.0,12.0], Vector[13.0,14.0,15.0,16.0,17.0,18.0])
    assert_equal Matrix[[1.0,14.0,9.0],[16.0,11.0,6.0]], sign(Matrix[[1.0,-1.0,0.0],[-1.0,0.0,1.0]], Matrix[[1.0,2.0,3.0],[4.0,5.0,6.0]], Matrix[[7.0,8.0,9.0],[10.0,11.0,12.0]], Matrix[[13.0,14.0,15.0],[16.0,17.0,18.0]])
  end
  def test_softmax
    assert_equal Vector[0.0417725705,0.1135496194,0.0056533027,0.8390245075], [1.0,2.0,-1.0,4.0].softmax.to_vector.round(10)
    assert_equal Vector[0.0417725705,0.1135496194,0.0056533027,0.8390245075], Vector[1.0,2.0,-1.0,4.0].softmax.round(10)
    assert_equal Matrix[[0.0417725705,0.1135496194,0.0056533027,0.8390245075],[0.0898823601,0.2443255861,0.0016462528,0.664145801]], Matrix[[1.0,2.0,-1.0,4.0],[2.0,3.0,-2.0,4.0]].softmax_rows.round(10)
  end
end
