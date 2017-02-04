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
    return old_add(y)
  end
  def -(y)
    return (-y).add!(self) if y.is_a? Matrix or y.is_a? Vector
    return old_sub(y)
  end
  def *(y)
    return y * self if y.is_a? Matrix or y.is_a? Vector
    return old_mul(y)
  end
  def /(y)
    return y.power_elements(-1).hadamard!(self) if y.is_a? Matrix or y.is_a? Vector
    return old_div(y)
  end
end

class Array
  def to_matrix
    Matrix::from_a(self)
  end
  def to_vector
    Vector::from_a(self)
  end
end

# Assume that _A is symmetric Matrix for fast computation.
def eigen_system_symmetric(_A, with_vectors: true)
  _Acopy = _A.copy
  lambdas = Vector.new(_A.nrows)
  info = LAPACK::dsyev(:LAPACK_COL_MAJOR, if with_vectors then 'V'.ord else 'N'.ord end, 'U'.ord, _Acopy.ncols, _Acopy.p, _Acopy.nrows, lambdas.p)
  raise LAPACK::Info.new(:dsyev, info) unless info == 0
  if with_vectors then [lambdas, _Acopy] else lambdas end
end
def eigen_values_symmetric(_A)
  eigen_system_symmetric(_A, with_vectors: false)
end

# Solve the following Weighted Least Squares problem:
#   min_{\bm{x} \in \mathbb{R}^m} (\bm{y} - A\bm{x})^\top diag(\bm{w}) (\bm{y} - A\bm{x}),
#     \bm{y} \in \mathbb{R}^m, A: m \times n-matrix, \bm{w} \in \mathbb{R}^m
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
  jpvt = FFI::MemoryPointer.new(:int, _A.ncols)
  rcond = 1.0e-05
  rank = FFI::MemoryPointer.new(:int, 1)
  info = LAPACK::dgelsy(:LAPACK_COL_MAJOR, _Acopy.nrows, _Acopy.ncols, 1, _Acopy.p, _Acopy.nrows, ycopy.p, ycopy.length, jpvt, rcond, rank)
  raise LAPACK::Info.new(:dgelsy, info) unless info == 0
  ycopy.resize(_A.ncols)
end
