require 'hako/data_frame'

module LIBMATH
  extend FFI::Library
  ffi_lib File.join(File.dirname(__FILE__), '../.build/libmath.dylib')
  attach_function :dexp, [:int, :pointer, :int], :void
end

class Float
  # Returns self/y unless y == 0, or returns +-inf.
  def divorinf(y)
    if y == 0 then (if self > 0 then 1 else -1 end)*Float::INFINITY else self/y end
  end
end

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
