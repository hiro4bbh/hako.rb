require 'hako/data_frame'

module LIBMATH
  extend FFI::Library
  ffi_lib File.join(File.dirname(__FILE__), '../.build/libmath.dylib')
  attach_function :dsign, [:int, :pointer, :int, :pointer, :int, :pointer, :int, :pointer, :int, :pointer, :int], :void
  attach_function :dexp, [:int, :pointer, :int], :void
end

class Float
  # Returns self/y unless y == 0, or returns +-inf.
  def divorinf(y)
    if y == 0 then (if self > 0 then 1 else -1 end)*Float::INFINITY else self/y end
  end
end

# Return element-wise substitution if c > 0 then p else if c == 0 then z
# else n.
#
# @param c Vector or Matrix.
# @param p Vector, Matrix or Numeric.
# @param z Vector, Matrix or Numeric.
# @param n Vector, Matrix or Numeric.
def sign(c, p, z, n)
  raise 'c must be Vector or Matrix' unless c.is_a? Vector or c.is_a? Matrix
  raise 'p must be Vector, Matrix or Numeric' unless p.is_a? Vector or p.is_a? Matrix or p.is_a? Numeric
  raise 'z must be Vector, Matrix or Numeric' unless z.is_a? Vector or z.is_a? Matrix or z.is_a? Numeric
  raise 'n must be Vector, Matrix or Numeric' unless n.is_a? Vector or n.is_a? Matrix or n.is_a? Numeric
  x = if c.is_a? Vector then Vector.new(c.length) else Matrix.new(c.nrows, c.ncols) end
  c = c.to_vector
  p = p.to_vector unless p.is_a? Numeric
  z = z.to_vector unless z.is_a? Numeric
  n = n.to_vector unless n.is_a? Numeric
  raise 'size of c and p must be equal' unless p.is_a? Numeric or c.length == p.length
  raise 'size of c and z must be equal' unless z.is_a? Numeric or c.length == z.length
  raise 'size of c and n must be equal' unless n.is_a? Numeric or c.length == n.length
  LIBMATH::dsign(
    x.length, x.p, 1, c.p, 1,
    if p.is_a? Numeric then Vector[p].p else p.p end, if p.is_a? Numeric then 0 else 1 end,
    if z.is_a? Numeric then Vector[z].p else z.p end, if z.is_a? Numeric then 0 else 1 end,
    if n.is_a? Numeric then Vector[n].p else n.p end, if n.is_a? Numeric then 0 else 1 end)
  x
end

# Return exp(v) element-wisely.
#
# @param v Vector
def exp(v)
  raise 'v must be Vector' unless v.is_a? Vector
  LIBMATH::dexp(v.length, v.p, 1)
end

class Array
  # Do softmax on self.
  def softmax!
    max_z = max
    nconst = 0.0
    length.times do |i| nconst += self[i] = Math::exp(self[i] - max_z) end
    length.times do |i| self[i] /= nconst end
    self
  end
  # (see #softmax!)
  def softmax
    copy.softmax!
  end
end

class Vector
  # Do softmax on self.
  def softmax!
    max_z = max
    nconst = 0.0
    length.times do |i| nconst += self[i] = Math::exp(self[i] - max_z) end
    self.div!(nconst)
  end
  # (see #softmax!)
  def softmax
    copy.softmax!
  end
end

class Matrix
  # Do softmax on rows in self.
  def softmax_rows!
    # This code is optimized with internal manipulation.
    max_x = rowmaxs
    each do |x| x.sub!(max_x) end
    exp(to_vector)
    mul_rows!(rowsums.power_elements(-1.0))
  end
  # (see #softmax_rows!)
  def softmax_rows
    copy.softmax_rows!
  end
end
