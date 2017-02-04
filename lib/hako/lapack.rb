require 'ffi'

$HAKO_LIBBLAS_PATH ||= '/usr/local/opt/openblas/lib/libopenblas.dylib'

module LAPACK
  extend FFI::Library
  ffi_lib $HAKO_LIBBLAS_PATH

  typedef :int, :lapack_int

  enum :LAPACK_LAYOUT, [
    :LAPACK_ROW_MAJOR, 101, :LAPACK_COL_MAJOR
  ]

  # lapack_int LAPACKE_dgelsy( int matrix_layout, lapack_int m, lapack_int n,
  #                            lapack_int nrhs, double* a, lapack_int lda,
  #                            double* b, lapack_int ldb, lapack_int* jpvt,
  #                            double rcond, lapack_int* rank )
  attach_function :dgelsy, :LAPACKE_dgelsy, [:int, :lapack_int, :lapack_int, :lapack_int, :pointer, :lapack_int, :pointer, :lapack_int, :pointer, :double, :pointer], :lapack_int
  # lapack_int LAPACKE_dgeqp3( int matrix_layout, lapack_int m, lapack_int n,
  #                            double* a, lapack_int lda, lapack_int* jpvt,
  #                            double* tau )
  attach_function :dgeqp3, :LAPACKE_dgeqp3, [:int, :lapack_int, :lapack_int, :pointer, :lapack_int, :pointer, :pointer], :lapack_int
  # void LAPACKE_dge_trans( int matrix_layout, lapack_int m, lapack_int n,
  #                         const double* in, lapack_int ldin,
  #                         double* out, lapack_int ldout )
  attach_function :dge_trans, :LAPACKE_dge_trans, [:int, :lapack_int, :lapack_int, :pointer, :lapack_int, :pointer, :lapack_int], :void
  # lapack_int LAPACKE_dorgqr( int matrix_layout, lapack_int m, lapack_int n,
  #                            lapack_int k, double* a, lapack_int lda,
  #                            const double* tau )
  attach_function :dorgqr, :LAPACKE_dorgqr, [:int, :lapack_int, :lapack_int, :lapack_int, :pointer, :lapack_int, :pointer], :lapack_int
  # lapack_int LAPACKE_dsyev( int matrix_layout, char jobz, char uplo, lapack_int n,
  #                           double* a, lapack_int lda, double* w )
  attach_function :dsyev, :LAPACKE_dsyev, [:int, :char, :char, :lapack_int, :pointer, :lapack_int, :pointer], :int

  class Info < Exception
    attr_reader :where, :info
    def initialize(where, info)
      @where = where
      @info = info
    end
    def inspect
      "LAPACK::Info<where=#{where.inspect}, info=#{info}>"
    end
    alias to_s inspect
  end
end
