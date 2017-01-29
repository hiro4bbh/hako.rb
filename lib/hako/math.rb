require 'hako/data_frame'

class Float
  # Returns self/y unless y == 0, or returns +-inf.
  def divorinf(y)
    if y == 0 then (if self > 0 then 1 else -1 end)*Float::INFINITY else self/y end
  end
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
    i = 0
    while i < nrows do
      o, endo = i*8, (i + ncols*nrows)*8
      max_z = p.get_float64(o)
      while o < endo do
        x = p.get_float64(o)
        max_z = x if max_z < x
        o += nrows*8
      end
      o, endo = i*8, (i + ncols*nrows)*8
      while o < endo do
        p.put_float64(o, Math::exp(p.get_float64(o) - max_z))
        o += nrows*8
      end
      i += 1
    end
    mul_rows!(rowsums.power_elements(-1.0))
  end
  # (see #softmax_rows!)
  def softmax_rows
    copy.softmax_rows!
  end
end
