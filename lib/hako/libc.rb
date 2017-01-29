require 'ffi'

module LibC
  extend FFI::Library
  ffi_lib FFI::Library::LIBC
  # int memcmp(const void *s1, const void *s2, size_t n);
  attach_function :memcmp, [:pointer, :pointer, :size_t], :int
  # void *memset(void *b, int c, size_t len); 
  attach_function :memset, [:pointer, :pointer, :size_t], :void
  # void memset_pattern4(void *b, const void *c4, size_t len);
  attach_function :memset_pattern4, [:pointer, :pointer, :size_t], :void
  # void memset_pattern8(void *b, const void *c8, size_t len);
  attach_function :memset_pattern8, [:pointer, :pointer, :size_t], :void
  # void memset_pattern16(void *b, const void *c16, size_t len);
  attach_function :memset_pattern16, [:pointer, :pointer, :size_t], :void
end
