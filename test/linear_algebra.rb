require 'hako.rb'

require 'minitest/autorun'

class TestLinearAlgebra < MiniTest::Test
  def test_decompose
    def test_decompose_QRP(_A)
      _Q, _R, pivot = decompose_QRP(_A)
      assert_equal (_Q*_R).project(pivot.invert_array).round!(10), _A.round!(10)
    end
    test_decompose_QRP Matrix[[2.0,0.0],[0.0,1.0]]
    test_decompose_QRP Matrix[[2.0,0.0],[0.0,0.0],[0.0,1.0]]
    test_decompose_QRP Matrix[[1.0,2.0,3.0],[4.0,5.0,6.0]]
    test_decompose_QRP Matrix[[1.0,2.0],[3.0,4.0],[5.0,6.0]]
    test_decompose_QRP Matrix.new(3, 3)
    test_decompose_QRP Matrix.new(3, 3).fill(1.0)
  end
  def test_eigen_system
    _A = Matrix[[1.0,2.0,3.0],[2.0,4.0,5.0],[3.0,5.0,6.0]]
    lambdas, _V = eigen_system_symmetric(_A, with_vectors: true)
    assert_equal _A, (_V*Matrix::diag(lambdas)*_V.t).round(10)
    lambdas2 = eigen_values_symmetric(_A)
    assert_equal lambdas.round(10), lambdas2.round(10)
  end
  def test_solve_weighted_least_squares
    # Lawn Roller data from
    #   Maindonald, John, and John Braun. Data analysis and graphics using R: an example-based approach. Vol. 10. Cambridge University Press, 2006.
    roller_weight = Vector[1.9,3.1,3.3,4.8,5.3,6.1,6.4,7.6,9.8,12.4]
    roller_intercept_depression = Matrix[[1,1,1,1,1,1,1,1,1,1],[2,1,5,5,20,20,23,10,30,25]].t
    assert_equal Vector[2.66233,0.24168], solve_weighted_least_squares(roller_weight, roller_intercept_depression).round(5)
    assert_equal Vector[3.29946,0.23199], solve_weighted_least_squares(roller_weight, roller_intercept_depression, (1..10).to_a.to_vector).round(5)
    assert_equal Vector[3.63323,0.22060], solve_weighted_least_squares(roller_weight, roller_intercept_depression, (0..9).to_a.to_vector).round(5)

    life_cycle_savings = Dataset::life_cycle_savings
    life_cycle_savings_sr = life_cycle_savings.project(:sr).to_matrix.to_vector
    life_cycle_savings_covariates = life_cycle_savings.project(1..-1).to_matrix
    assert_equal Vector[0.09172,1.71394,0.00026,0.55316], solve_weighted_least_squares(life_cycle_savings_sr, life_cycle_savings_covariates).round(5)
    assert_equal Vector[0.11656,2.03155,-0.00038,0.27820], solve_weighted_least_squares(life_cycle_savings_sr, life_cycle_savings_covariates, (1..(life_cycle_savings.nrows)).to_a.to_vector).round(5)
    assert_equal Vector[0.11745,2.04208,-0.00041,0.26980], solve_weighted_least_squares(life_cycle_savings_sr, life_cycle_savings_covariates, (0..(life_cycle_savings.nrows - 1)).to_a.to_vector).round(5)
  end
end
