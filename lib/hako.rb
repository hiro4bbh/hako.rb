require 'set'
require 'zlib'

require 'hako/linear_algebra'
require 'hako/data_frame'
require 'hako/math'
require 'hako/dataset'
require 'hako/shell'

class Object
  alias copy clone
end

class String
  # Returns type infered from self.
  def infer_type
    if (Integer(self) rescue nil) then Integer
    elsif (Float(self) rescue nil) then Float
    else String
    end
  end
end

class Symbol
  # FIXME: Ruby 2.4.0 has a bug that Symbol converted from String at first cannot be cloned.
  # For details, see https://bugs.ruby-lang.org/issues/13145 .
  def clone
    self
  end
  alias copy clone
end

class Array
  def copy
    other = clone
    each.with_index do |x, i| other[i] = x.copy end
    other
  end
  # Returns type indicating inferred with elements in self.
  def infer_string_type
    types = [nil]
    each do |val| merge_types(types, [val.to_s.infer_type]) end
    types[0]
  end
  # Returns type Array indicating inferred types respectively.
  def infer_string_types
    collect do |obj| obj.to_s.infer_type end
  end
end

# Returns types merged with ts.
#
# @param types merged type Array (overwritten).
# @param ts type Array.
def merge_types(types, ts)
  raise "length of types must be equal to length of ts" unless types.length == ts.length
  types.collect!.with_index do |type, i|
    if type == nil then ts[i]
    elsif type <= Integer then (if ts[i] <= Integer then Integer elsif ts[i] <= Numeric then Float else Object end)
    elsif type <= Float then (if ts[i] <= Numeric then Float else Object end)
    else String
    end
  end
end

class Hash
  def copy
    other = clone
    each do |k, v| other[k] = v.copy end
    other
  end
  # Returns new OrderedHash converted from self.
  def to_ordered_hash
    OrderedHash.new(self)
  end
end

# OrderedHash is Hash extension ordered by user.
#
# NOTICE: Currently OrderedHash is tested via rowname operations in
# DataFrame.
class OrderedHash
  # Keys is interface for keys Array in OrderedHash
  class Keys
    # DO NOT use this externally, because OrderedHash correctly uses this.
    #
    # @param h Hash object.
    # @para, keys Array of keys.
    def initialize(h, keys=nil)
      @h = h
      @keys = keys || h.keys
    end
    # Returns new Keys affiliated with h.
    def Keys.affiliate(h, keys)
      if keys.is_a? Keys then keys.affiliate_with(h) else Keys.new(h, keys) end
    end
    def inspect
      "OrderedHash::Keys<keys=#{@keys}>"
    end
    alias to_s inspect
    def copy
      Keys.new(@h, @keys.copy)
    end
    # Affiliate to h.
    #
    # @param h Hash object affiliated with self.
    def affiliate_with(h)
      Keys.new(h, @keys.copy)
    end
    # Returns length of self.
    def length
      @keys.length
    end
    alias size length

    # Iterates keys in order.
    def each
      return to_enum unless block_given?
      @keys.each do |key| yield key end
      self
    end
    # Returns i-th key.
    #
    # @param i index.
    def [](i)
      @keys[i]
    end

    # Set key at i-th.
    #
    # @param i index.
    # @param key key Object.
    def []=(i, key)
      return key if @keys[i] == key
      return @keys[i] = key unless @keys[i]
      oldkey = @keys[i]
      raise 'detected duplicated key' if @h[key]
      @keys[i] = key
      @h[key] = @h.delete(oldkey)
      key
    end
    # Append key.
    #
    # @param key key Object.
    def <<(key)
      raise "#{key.inspect} is already used" if @h[key]
      @keys << key
    end
    # Delete key.
    #
    # @param key key Object.
    def delete(key)
      return nil unless @h[key]
      value = @h[key]
      delete_at(index(key))
      return value
    end
    # Delete i-th key.
    #
    # @param i index.
    def delete_at(i)
      i = length + i if i < 0
      return nil unless 0 <= i and i < length
      key = @keys.delete_at(i)
      @h.delete(key)
      key
    end
    # Fill keys with ks whose duplicated elements are removed.
    #
    # @param ks Array or Object which can be converted into Array.
    def fill(ks)
      case ks
      when Range then
        ks = ks.last.upto(ks.first).collect do |i| i end if ks.first > ks.last
      end
      ks = ks.to_a.uniq
      raise "ks must have #{length} elements" unless ks.length == length
      ks.each.with_index do |key, i| self[i] = key end
      self
    end
  end

  include Enumerable
  attr_reader :keys
  # Returns new OrderedHash converted from h with order specified by keys.
  #
  # @param h Hash.
  # @param keys Array indicating key order.
  def initialize(h, keys=nil)
    @h = h
    @keys = Keys.affiliate(h, keys)
  end
  def inspect
    "{#{@keys.collect do |key| "#{key.inspect}=>#{@h[key].inspect}" end.join(', ')}}"
  end
  alias to_s inspect
  # Converts self into OrderedHash, so simply returns self.
  def to_ordered_hash
    self
  end
  def copy
    OrderedHash.new(@h.copy, @keys.copy)
  end
  # Returns size of self.
  def size
    @keys.length
  end

  # Returns value by key.
  #
  # @param key key Object.
  def [](key)
    @h[key]
  end
  # Iterates key values in order.
  def each
    return to_enum unless block_given?
    @keys.each do |key| yield(key, @h[key]) if key end
    self
  end

  # Set key value.
  #
  # @param key key Object.
  # @param value value Object.
  def []=(key, value)
    @keys << key unless @h.has_key?(key)
    @h[key] = value
  end
  # Delete key.
  #
  # @param key key Object.
  def delete(key)
    keys.delete(key)
  end
  # Rename newkey from oldkey.
  #
  # @param oldkey old key Object.
  # @param newkey new key Object.
  def rename(oldkey, newkey)
    raise "#{oldkey.inspect} not found" unless @h[oldkey]
    @keys[@keys.index(oldkey)] = newkey
    newkey
  end
end

class SortedSet
  # Return the Array of keys.
  def keys
    to_a
  end
  # Return the inverted Hash mapping a key Object to the corresponding
  # index in sorted order.
  def invert
    unless (@invert_map_keys ||= nil) === keys then
      @invert_map_keys = keys
      @invert_map = {}
      @invert_map_keys.each.with_index do |key, i| @invert_map[key] = i end
    end
    @invert_map
  end
end

# Writes marshalized Object obj into gunziped file.
#
# @param path file path.
# @param obj marshalized Object.
def dump_object(path, obj)
  Zlib::GzipWriter.open(path) do |gz|
    Marshal.dump(obj, gz)
  end
  return
end
# Returns unmarshalized Object from gunziped file.
#
# @param path file path.
def load_object(path)
  Zlib::GzipReader.open(path) do |gz|
    Marshal.load(gz)
  end
end

module FFI
  class MemoryPointer
    # Returns marshalized representation.
    def marshal_dump
      get_bytes(0, size)
    end
    # Rewrites self with marshalized representation.
    #
    # @param obj marshalized representation.
    def marshal_load(obj)
      p = FFI::MemoryPointer.new(obj.length)
      p.put_bytes(0, obj)
      initialize_copy(p)
    end
  end
end
