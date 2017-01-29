require 'hako'

require 'minitest/autorun'

class TestDataFrame < MiniTest::Test
  def test_softmax
    assert_equal Vector[0.0417725705,0.1135496194,0.0056533027,0.8390245075], [1.0,2.0,-1.0,4.0].softmax.to_vector.round(10)
    assert_equal Vector[0.0417725705,0.1135496194,0.0056533027,0.8390245075], Vector[1.0,2.0,-1.0,4.0].softmax.round(10)
    assert_equal Matrix[[0.0417725705,0.1135496194,0.0056533027,0.8390245075],[0.0898823601,0.2443255861,0.0016462528,0.664145801]], Matrix[[1.0,2.0,-1.0,4.0],[2.0,3.0,-2.0,4.0]].softmax_rows.round(10)
  end
end
