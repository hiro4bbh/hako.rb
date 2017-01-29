require 'ffi'

class Matrix
  attr_reader :p, :nrows, :ncols
  def initialize(nrows, ncols, p=nil)
    @p = if p then p else FFI::MemoryPointer.new(:double, nrows*ncols) end
    @nrows = nrows
    @ncols = ncols
  end
  def Matrix::[](*a)
    Matrix::from_a(a)
  end
  def Matrix::diag(v)
    raise "v must be Vector" unless v.is_a? Vector
    _A = Matrix::new(v.length, v.length)
    v.length.times do |i| _A[i,i] = v[i] end
    _A
  end
  def Matrix::from_a(a)
    raise 'a must be non-empty Array' unless a.is_a? Array and a.length >= 1
    a.each do |b| raise 'Array must form Matrix' unless b.is_a? Array and b.length == a.first.length end
    _A = Matrix::new(a.length, a.first.length)
    a.each.with_index do |b, i|
      b.each.with_index do |x, j|
        _A[i,j] = x
      end
    end
    _A
  end
  def Matrix::I(n)
    _A = Matrix.new(n, n)
    n.times do |i| _A[i,i] = 1.0 end
    _A
  end
  def inspect
    "Matrix[#{nrows.times.map do |i| "[#{ncols.times.map do |j| self[i,j] end.join(',')}]" end.join(',')}]"
  end
  alias to_s inspect
  def length
    nrows*ncols
  end
  def copy
    other = Matrix.new(nrows, ncols)
    other.p.__copy_from__(p, nrows*ncols*8)
    other
  end
  def resize(newnrows, newncols, fillval=nil)
    newA = Matrix.new(newnrows, newncols)
    if fillval then
      raise 'fillval must be Float' unless fillval.is_a? Float
      newA.fill(fillval)
    end
    min_nrows = [nrows, newnrows].min
    [ncols, newncols].min.times do |j|
      (newA.p + j*newnrows*8).__copy_from__(p + j*nrows*8, min_nrows*8)
    end
    newA
  end
  def to_a
    nrows.times.map do |i| ncols.times.map do |j| self[i,j] end end
  end
  def to_data_frame(colnames: nil)
    colnames = ncols.times.map do |i| "V#{i}" end unless colnames
    df = DataFrame.from_a([], colnames: colnames)
    nrows.times do |i|
      a = Array.new(ncols)
      ncols.times do |j| a[j] = self[i,j] end
      df << a
    end
    df
  end
  def to_matrix
    self
  end
  def to_vector
    Vector.new(nrows*ncols, p)
  end

  def [](i, j)
    raise 'i and j must be Integer' unless i.is_a? Integer and j.is_a? Integer
    i = nrows + i if i < 0
    j = ncols + j if j < 0
    raise 'i is out of index' unless 0 <= i and i < nrows
    raise 'j is out of index' unless 0 <= j and j < ncols
    p.get_float64((i + j*nrows)*8)
  end
  def []=(i, j, value)
    raise 'i and j must be Integer' unless i.is_a? Integer and j.is_a? Integer
    i = nrows + i if i < 0
    j = ncols + j if j < 0
    raise 'i is out of index' unless 0 <= i and i < nrows
    raise 'j is out of index' unless 0 <= j and j < ncols
    raise 'value must be Numeric' unless value.is_a? Numeric
    p.put_float64((i + j*nrows)*8, value)
    value
  end

  def +@
    self
  end
  def -@
    self*(-1)
  end
  def +(y)
    copy.add!(y)
  end
  def -(y)
    copy.sub!(y)
  end
  def *(y)
    if y.is_a? Matrix then
      raise "number of columns of self and number of rows of y must be equal" unless ncols == y.nrows
      _A = Matrix.new(nrows, y.ncols)
      BLAS::dgemm(:CblasColMajor, :CblasNoTrans, :CblasNoTrans, _A.nrows, _A.ncols, ncols, 1.0, p, nrows, y.p, y.nrows, 0.0, _A.p, _A.nrows)
      return _A
    elsif y.is_a? Vector then
      raise "number of columns of self and length of y must be equal" unless ncols == y.length
      return self * y.to_matrix(y.length, 1)
    end
    copy.mul!(y)
  end
  def /(y)
    copy.div!(y)
  end
  def ==(y)
    y.is_a? Matrix and nrows == y.nrows and ncols == y.ncols and LibC::memcmp(p, y.p, nrows*ncols*8) == 0
  end
  def add!(y)
    self.to_vector.add!(if y.is_a? Numeric then y else y.to_vector end)
    self
  end
  def div!(y)
    raise "y must be Numeric" unless y.is_a? Numeric
    to_vector.div!(y)
    self
  end
  def hadamard!(y)
    to_vector.hadamard!(if y.is_a? Numeric then y else y.to_vector end)
    self
  end
  def hadamard(y)
    self.copy.hadamard!(y)
  end
  def mul!(y)
    raise "y must be Numeric" unless y.is_a? Numeric
    to_vector.mul!(y)
    self
  end
  def mul_rows(v)
    copy.mul_rows!(v)
  end
  def mul_rows!(v)
    ncols.times do |j|
      Vector.new(nrows, p + j*nrows*8).hadamard!(v)
    end
    self
  end
  def power_elements!(alpha, non_finite_alt=Float::NAN)
    to_vector.power_elements!(alpha, non_finite_alt)
    self
  end
  def power_elements(alpha, non_finite_alt=Float::NAN)
    copy.power_elements!(alpha, non_finite_alt)
  end
  def sub!(y)
    add!(-y)
  end
  def t
    selft = Matrix::new(ncols, nrows)
    LAPACK::dge_trans(:LAPACK_COL_MAJOR, nrows, ncols, p, nrows, selft.p, selft.nrows)
    selft
  end

  def collect_columns(js)
    _A = Matrix::new(nrows, js.length)
    js.each.with_index do |j, jo| (_A.p + jo*_A.nrows*8).__copy_from__(p + j*nrows*8, nrows*8) end
    _A
  end
  def collect_rows(is)
    self.t.collect_columns(is).t
  end
  def colsums
    v = Vector.new(ncols)
    ncols.times do |j| v[j] = Vector.new(nrows, p + j*nrows*8).sum end
    v
  end
  def diag
    d = Vector.new([nrows, ncols].min)
    d.length.times do |i| d[i] = self[i,i] end
    d
  end
  def max
    to_vector.max
  end
  def min
    to_vector.min
  end
  def round(ndigits=0)
    copy.round!(ndigits)
  end
  def round!(ndigits=0)
    to_vector.round!(ndigits)
    self
  end
  def rowsums
    (self * Vector.new(ncols).fill(1.0)).to_vector
  end
end