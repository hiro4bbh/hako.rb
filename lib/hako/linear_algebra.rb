require 'ffi'

require 'hako/libc'
require 'hako/blas'
require 'hako/lapack'
require 'hako/vector'
require 'hako/matrix'

class Float
  alias old_add +
  alias old_sub -
  alias old_mul *
  alias old_div /
  def +(y)
    return y + self if y.is_a? Matrix or y.is_a? Vector
    old_add(y)
  end
  def -(y)
    return (-y).add!(self) if y.is_a? Matrix or y.is_a? Vector
    old_sub(y)
  end
  def *(y)
    return y*self if y.is_a? Matrix or y.is_a? Vector
    old_mul(y)
  end
  def /(y)
    return y.power_elements(-1).hadamard!(self) if y.is_a? Matrix or y.is_a? Vector
    old_div(y)
  end
end

class Array
  def to_matrix
    Matrix::from_a(self)
  end
  def to_vector
    Vector::from_a(self)
  end
  # Return inverse index Array for index Array.
  def invert_array
    a = Array.new(length)
    each.with_index do |x, i| a[x] = i end
    a
  end
end

# Decompose _A as Q * R * P, and return (Q, R, P).
# Q is $m times \min\{m, n\}$ Matrix which consists of leading columns of
# orthogonal matrix $Q$.
# R is $\min\{m, n\} \times n$ upper triangular Matrix.
# P is represented as column pivot indices Array.
#
# @param _A Matrix.
def decompose_QRP(_A)
  _Acopy = _A.copy
  pivot = FFI::MemoryPointer.new(LAPACK::find_type(:lapack_int), _A.ncols)
  max_rank = [_A.nrows, _A.ncols].min
  tau = Vector.new(max_rank)
  info = LAPACK::dgeqp3(:LAPACK_COL_MAJOR, _A.nrows, _A.ncols, _Acopy.p, _A.nrows, pivot, tau.p)
  raise LAPACK::Info.new(:dgeqp3, info) unless info == 0
  _R = Matrix.new(max_rank, _A.ncols)
  i = 0
  while i < max_rank do
    j = i
    while j < _A.ncols do
      _R[i,j] = _Acopy[i,j]
      j += 1
    end
    i += 1
  end
  info = LAPACK::dorgqr(:LAPACK_COL_MAJOR, _A.nrows, max_rank, max_rank, _Acopy.p, _A.nrows, tau.p)
  [_Acopy.resize(_A.nrows, max_rank), _R, pivot.get_bytes(0, pivot.size).unpack('i*').collect!.with_index do |j, jo| if j == 0 then jo else j - 1 end end]
end

# Return eigen values and corresponding eigen vectors if with_vectors is
# true.
# This assumes that _A is symmetric Matrix for fast computation.
# Eigen vectors are returned in Matrix whose columns are those in order
# indicated by eigen values.
#
# @param _A symmetric Matrix.
# @param with_vectors returns all eigen vectors also if true.
def eigen_system_symmetric(_A, with_vectors: true)
  _Acopy = _A.copy
  lambdas = Vector.new(_A.nrows)
  info = LAPACK::dsyev(:LAPACK_COL_MAJOR, if with_vectors then 'V'.ord else 'N'.ord end, 'U'.ord, _Acopy.ncols, _Acopy.p, _Acopy.nrows, lambdas.p)
  raise LAPACK::Info.new(:dsyev, info) unless info == 0
  if with_vectors then [lambdas, _Acopy] else lambdas end
end
# (see #eigen_system_symmetric)
def eigen_values_symmetric(_A)
  eigen_system_symmetric(_A, with_vectors: false)
end

# Solve the linear equation AX = B.
#
# @param A Matrix.
# @param B Vector or Matrix.
def solve_linear_equation(_A, _B)
  raise '_A must be Matrix' unless _A.is_a? Matrix
  raise '_B must be Vector or Matrix' unless _B.is_a? Vector or _B.is_a? Matrix
  _Acopy, _Bcopy = _A.copy, if _B.is_a? Vector then _B.resize([_A.ncols, _B.length].max) else _B.resize([_A.ncols, _B.nrows].max, _B.ncols) end
  jpvt = FFI::MemoryPointer.new(:int, _A.ncols)
  rcond = 1.0e-05
  rank = FFI::MemoryPointer.new(:int, 1)
  info = LAPACK::dgelsy(:LAPACK_COL_MAJOR, _Acopy.nrows, _Acopy.ncols, if _Bcopy.is_a? Vector then 1 else _Bcopy.ncols end, _Acopy.p, _Acopy.nrows, _Bcopy.p, if _Bcopy.is_a? Vector then _Bcopy.length else _Bcopy.nrows end, jpvt, rcond, rank)
  raise LAPACK::Info.new(:dgelsy, info) unless info == 0
  if _Bcopy.is_a? Vector then _Bcopy.resize(_A.ncols) else _Bcopy.resize(_A.ncols, _Bcopy.ncols) end
end

# Solve the following Weighted Least Squares problem:
#   \min_{\bm{x} \in \mathbb{R}^m} (\bm{y} - A\bm{x})^\top \diag(\bm{w}) (\bm{y} - A\bm{x}),
#     \bm{y} \in \mathbb{R}^m, A: m \times n, \bm{w} \in \mathbb{R}^m
#
# @param y Vector.
# @param _A Matrix.
# @param w weight Vector. If this is omitted, weights are treated as uniform.
def solve_weighted_least_squares(y, _A, w=nil)
  raise "y must be Vector" unless y.is_a? Vector
  raise "_A must be Matrix" unless _A.is_a? Matrix
  raise "length of y and number of rows of A must be equal" unless y.length == _A.nrows
  ycopy, _Acopy = if w then
    raise "w must be Vector" unless w.is_a? Vector
    raise "length of w and y must be equal" unless w.length == y.length
    wsqrt = w.power_elements(0.5)
    [if y.length < _A.ncols then y.hadamard(wsqrt).resize(_A.ncols) else y.hadamard(wsqrt) end, _A.mul_rows(wsqrt)]
  else
    [if y.length < _A.ncols then y.resize(_A.ncols) else y.copy end, _A.copy]
  end
  return solve_linear_equation(_Acopy, ycopy)
end

# Solve the following multiple Weighted Least Squares problem for k = 1,\ldots,K:
#   \min_{\bm{x}_k \in \mathbb{R}^m} (\bm{y}_k - A\bm{x})^\top \diag(\bm{w}_k) (\bm{y}_k - A\bm{x}),
#     Y := (\bm{y}_1,\ldots,\bm{y}_K): m \times K, A: m \times n,
#     W := (\bm{w}_1,\ldots,\bm{w}_K): m \times K
#
# @param _Y Matrix
# @param _A Matrix
# @param _W Matrix if set
def solve_multiple_weighted_least_squares(_Y, _A, _W=nil)
  raise "_Y must be Matrix" unless _Y.is_a? Matrix
  raise "_A must be Matrix" unless _A.is_a? Matrix
  raise "number of rows of _Y and A must be equal" unless _Y.nrows == _A.nrows
  _W ||= Matrix.new(_Y.nrows, _Y.ncols).fill(1.0)
  raise "_W must be Matrix" unless _W.is_a? Matrix
  raise "number of rows of w and y must be equal" unless _W.nrows == _Y.nrows
  raise "number of columns of w and y must be equal" unless _W.ncols == _Y.ncols
  Matrix.new(_A.ncols, _Y.ncols).each.with_index do |x, j|
    x.fill(solve_weighted_least_squares(_Y.slice_columns(j).to_vector, _A, _W.slice_columns(j).to_vector))
  end
end
