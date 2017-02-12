require 'ffi'

$HAKO_LIBBLAS_PATH ||= '/usr/local/opt/openblas/lib/libopenblas.dylib'

module BLAS
  extend FFI::Library
  ffi_lib $HAKO_LIBBLAS_PATH

  # /*Get the number of threads on runtime.*/
  # int openblas_get_num_threads(void);
  attach_function :get_number_of_threads, :openblas_get_num_threads, [], :int

  # /*Get the number of physical processors (cores).*/
  # int openblas_get_num_procs(void);
  attach_function :get_number_of_processors, :openblas_get_num_procs, [], :int

  # /*Get the build configure on runtime.*/
  # char* openblas_get_config(void);
  attach_function :get_config, :openblas_get_config, [], :pointer

  # /* Get the parallelization type which is used by OpenBLAS */
  # int openblas_get_parallel(void);
  # /* OpenBLAS is compiled for sequential use  */
  # #define OPENBLAS_SEQUENTIAL  0
  # /* OpenBLAS is compiled using normal threading model */
  # #define OPENBLAS_THREAD  1
  # /* OpenBLAS is compiled using OpenMP threading model */
  # #define OPENBLAS_OPENMP 2
  enum :OPENBLAS_PARALLEL, [
    :OPENBLAS_SEQUENTIAL, 0, :OPENBLAS_THREAD, :OPENBLAS_OPENMP,
  ]
  attach_function :get_parallel, :openblas_get_parallel, [], :OPENBLAS_PARALLEL

  def BLAS::get_configure
    {
      :nthreads => get_number_of_threads, :nprocs => get_number_of_processors,
      :config => get_config.get_string(0),
      :parallel => get_parallel,
    }
  end
  def BLAS::get_configure_string
    config = get_configure
    "OpenBLAS (config: #{config[:config].inspect}, parallel: #{config[:parallel]}, nprocs: #{config[:nprocs]}, nthreads: #{config[:nthreads]})"
  end

  typedef :int, :blasint
  # typedef enum CBLAS_ORDER     {CblasRowMajor=101, CblasColMajor=102} CBLAS_ORDER;
  enum :CBLAS_ORDER, [
    :CblasRowMajor, 101, :CblasColMajor,
  ]
  # typedef enum CBLAS_TRANSPOSE {CblasNoTrans=111, CblasTrans=112, CblasConjTrans=113, CblasConjNoTrans=114} CBLAS_TRANSPOSE;
  enum :CBLAS_TRANSPOSE, [
    :CblasNoTrans, 111, :CblasTrans, :CblasConjTrans, :CblasConjNoTrans,
  ]
  # typedef enum CBLAS_UPLO      {CblasUpper=121, CblasLower=122} CBLAS_UPLO;
  enum :CBLAS_UPLO, [
    :CblasUpper, 121, :CblasLower,
  ]
  # typedef enum CBLAS_DIAG      {CblasNonUnit=131, CblasUnit=132} CBLAS_DIAG;
  enum :CBLAS_DIAG, [
    :CblasNonUnit, 131, :CblasUnit,
  ]
  # typedef enum CBLAS_SIDE      {CblasLeft=141, CblasRight=142} CBLAS_SIDE;
  enum :CBLAS_SIDE, [
    :CblasLeft, 141, :CblasRight,
  ]

  # double BLASFUNC(dmax)  (blasint *, double *, blasint *);
  attach_function :dmax, :dmax_, [:pointer, :pointer, :pointer], :double
  # double BLASFUNC(dmin)  (blasint *, double *, blasint *);
  attach_function :dmin, :dmin_, [:pointer, :pointer, :pointer], :double
  # blasint    blasfunc(idmax) (blasint *, double *, blasint *);
  attach_function :idmax, :idmax_, [:pointer, :pointer, :pointer], :blasint
  # blasint    blasfunc(idmin) (blasint *, double *, blasint *);
  attach_function :idmin, :idmin_, [:pointer, :pointer, :pointer], :blasint

  # double cblas_dasum (OPENBLAS_CONST blasint n, OPENBLAS_CONST double *x, OPENBLAS_CONST blasint incx);
  attach_function :dasum, :cblas_dasum, [:blasint, :pointer, :blasint], :double
  # void cblas_daxpy(OPENBLAS_CONST blasint n, OPENBLAS_CONST double alpha, OPENBLAS_CONST double *x, OPENBLAS_CONST blasint incx, double *y, OPENBLAS_CONST blasint incy);
  attach_function :daxpy, :cblas_daxpy, [:blasint, :double, :pointer, :blasint, :pointer, :blasint], :void
  # double cblas_ddot(OPENBLAS_CONST blasint n, OPENBLAS_CONST double *x, OPENBLAS_CONST blasint incx, OPENBLAS_CONST double *y, OPENBLAS_CONST blasint incy);
  attach_function :ddot, :cblas_ddot, [:blasint, :pointer, :blasint, :pointer, :blasint], :double
  # void cblas_dger (OPENBLAS_CONST enum CBLAS_ORDER order, OPENBLAS_CONST blasint M, OPENBLAS_CONST blasint N, OPENBLAS_CONST double  alpha, OPENBLAS_CONST double *X, OPENBLAS_CONST blasint incX, OPENBLAS_CONST double *Y, OPENBLAS_CONST blasint incY, double *A, OPENBLAS_CONST blasint lda);
  attach_function :dger, :cblas_dger, [:CBLAS_ORDER, :blasint, :blasint, :double, :pointer, :blasint, :pointer, :blasint, :pointer, :blasint], :void
  # void cblas_dgemm(OPENBLAS_CONST enum CBLAS_ORDER Order, OPENBLAS_CONST enum CBLAS_TRANSPOSE TransA, OPENBLAS_CONST enum CBLAS_TRANSPOSE TransB, OPENBLAS_CONST blasint M, OPENBLAS_CONST blasint N, OPENBLAS_CONST blasint K,
	#                  OPENBLAS_CONST double alpha, OPENBLAS_CONST double *A, OPENBLAS_CONST blasint lda, OPENBLAS_CONST double *B, OPENBLAS_CONST blasint ldb, OPENBLAS_CONST double beta, double *C, OPENBLAS_CONST blasint ldc);
  attach_function :dgemm, :cblas_dgemm, [:CBLAS_ORDER, :CBLAS_TRANSPOSE, :CBLAS_TRANSPOSE, :blasint, :blasint, :blasint, :double, :pointer, :blasint, :pointer, :blasint, :double, :pointer, :blasint], :void
  # double cblas_dnrm2 (OPENBLAS_CONST blasint N, OPENBLAS_CONST double *X, OPENBLAS_CONST blasint incX);
  attach_function :dnrm2, :cblas_dnrm2, [:blasint, :pointer, :blasint], :double
  # void cblas_dscal(OPENBLAS_CONST blasint N, OPENBLAS_CONST double alpha, double *X, OPENBLAS_CONST blasint incX);
  attach_function :dscal, :cblas_dscal, [:blasint, :double, :pointer, :blasint], :void
end
