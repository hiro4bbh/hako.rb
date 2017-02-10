require 'ffi'

class Vector
  attr_reader :p, :length
  def initialize(length, p=nil)
    @p = if p then p else FFI::MemoryPointer.new(:double, length) end
    @length = length
  end
  def Vector::[](*a)
    Vector::from_a(a)
  end
  def Vector::from_a(a)
    raise "a must be Array" unless a.is_a? Array
    v = Vector.new(a.length)
    v.p.put_array_of_float64(0, a)
    v
  end
  def inspect
    "Vector[#{length.times.map do |i| self[i] end.join(',')}]"
  end
  alias to_s inspect
  def copy
    other = Vector.new(length)
    other.p.__copy_from__(p, length*8)
    other
  end
  def resize(newlen, fillval=nil)
    newv = Vector.new(newlen)
    if fillval then
      raise 'fillval must be Numeric' unless fillval.is_a? Numeric
      newv.fill(fillval)
    end
    newv.p.__copy_from__(p, [length, newlen].min*8)
    newv
  end
  def to_a
    @p.get_array_of_float64(0, length)
  end
  def to_matrix(nrows, ncols)
    Matrix::new(nrows, ncols, p)
  end
  def to_vector
    self
  end

  def [](idx)
    raise 'idx must be Integer' unless idx.is_a? Integer
    idx = length + idx if idx < 0
    raise 'idx is out of index' unless 0 <= idx and idx < length
    p.get_float64(idx*8)
  end
  def []=(idx, value)
    raise 'idx must be Integer' unless idx.is_a? Integer
    idx = length + idx if idx < 0
    raise 'idx is out of index' unless 0 <= idx and idx < length
    raise 'value must be Numeric' unless value.is_a? Numeric
    p.put_float64(idx*8, value)
    value
  end

  # Fills self with value.
  # If value is Vector, it must be same length with self.
  #
  # @param value Vector or Numeric.
  def fill(value)
    case value
    when Vector then
      raise 'length of self and value must be same' unless length == value.length
      p.__copy_from__(value.p, length*8)
    when Numeric then
      self[0] = value
      LibC::memset_pattern8(p + 8, p, (length - 1)*8)
    else
      raise 'value must be Vector or Numeric'
    end
    self
  end

  def +@
    self
  end
  def -@
    self*(-1)
  end
  def +(y)
    self.copy.add!(y)
  end
  def -(y)
    self.copy.add!(-y)
  end
  def *(y)
    if y.is_a? Matrix then
      raise "length of self and number of rows of y must be equal" unless length == y.nrows
      v = Vector.new(y.ncols)
      BLAS::dgemm(:CblasColMajor, :CblasTrans, :CblasNoTrans, y.ncols, 1, y.nrows, 1.0, y.p, y.nrows, p, length, 0.0, v.p, v.length)
      v
    else
      self.copy.hadamard!(y)
    end
  end
  def /(y)
    self.copy.div!(y)
  end
  def ==(y)
    y.is_a? Vector and length == y.length and LibC::memcmp(p, y.p, length*8) == 0
  end
  def add!(y)
    if y.is_a? Numeric then
      yv = Vector.new(1)
      yv[0] = y
      BLAS::daxpy(length, 1.0, yv.p, 0, p, 1)
    elsif y.is_a? Vector then
      BLAS::daxpy(length, 1.0, y.p, 1, p, 1)
    else
      raise "y must be Numeric or Vector"
    end
    self
  end
  def div!(y)
    raise "y must be Numeric" unless y.is_a? Numeric
    self.hadamard!(1.0/y)
  end
  def dot(y)
    raise "y must be corresponding Vector" unless y.is_a? Vector and y.length == length
    BLAS::ddot(length, p, 1, y.p, 1)
  end
  def hadamard!(y)
    if y.is_a? Numeric then
      BLAS::dscal(length, y, p, 1)
    elsif y.is_a? Vector then
      raise "self and y must have same length" unless self.length == y.length
      LIBMATH::dhad(length, p, 1, y.p, 1)
    else
      raise "y must be Numeric or Vector"
    end
    self
  end
  def hadamard(y)
    self.copy.hadamard!(y)
  end
  def mul!(y)
    raise "y must be Numeric" unless y.is_a? Numeric
    self.hadamard!(y)
  end
  def power_elements!(alpha, non_finite_alt=Float::NAN)
    LIBMATH::dpow(length, p, 1, alpha, non_finite_alt)
    self
  end
  def power_elements(alpha, non_finite_alt=Float::NAN)
    copy.power_elements!(alpha, non_finite_alt)
  end
  def sub!(y)
    add!(-y)
  end

  def l1norm
    BLAS::dasum(length, p, 1)
  end
  def l2norm
    BLAS::dnrm2(length, p, 1)
  end
  def max
    return Float::NAN if length == 0
    i1 = FFI::MemoryPointer.new(:int, 1)
    i1.put_bytes(0, [length].pack('i*'))
    i2 = FFI::MemoryPointer.new(:int, 1)
    i2.put_bytes(0, [1].pack('i*'))
    BLAS::dmax(i1, self.p, i2)
  end
  def min
    return Float::NAN if length == 0
    i1 = FFI::MemoryPointer.new(:int, 1)
    i1.put_bytes(0, [length].pack('i*'))
    i2 = FFI::MemoryPointer.new(:int, 1)
    i2.put_bytes(0, [1].pack('i*'))
    BLAS::dmin(i1, self.p, i2)
  end
  def rank1op(v)
    _A = Matrix.new(length, v.length)
    BLAS::dger(:CblasColMajor, length, v.length, 1.0, p, 1, v.p, 1, _A.p, _A.nrows)
    _A
  end
  def round(ndigits=0)
    self.copy.round!(ndigits)
  end
  def round!(ndigits=0)
    length.times do |i| self[i] = self[i].round(ndigits) end
    self
  end
  def sum
    BLAS::ddot(length, p, 1, Vector_1_1.p, 0)
  end
end

# For internal usage, but user can use this for efficiency.
Vector_1_1 = Vector[1.0]
