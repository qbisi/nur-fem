{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gfortran,
  pkg-config,
  precision ? "double",
  mpi,
  metis,
  zlib,
  blas,
  lapack,
  hypre,
  suitesparse,
  superlu_dist,
  mumps,
  petsc,
  slepc,
  adios2,
  llvmPackages,
  mpiCheckPhaseHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "mfem";
  version = "4.8";

  src = fetchFromGitHub {
    owner = "mfem";
    repo = "mfem";
    rev = "v${finalAttrs.version}";
    hash = "sha256-IxMWhv4XYCOlovl7qkxEUgNwhl+qh+KGP22fhGrqHUM=";
  };

  nativeBuildInputs = [
    cmake
    gfortran
    pkg-config
  ];

  buildInputs =
    [
      mpi
      metis
      zlib
      blas
      lapack
      hypre
      suitesparse
      superlu_dist
      petsc
      slepc
      adios2
      (mumps.override { mpiSupport = true; })
    ]
    ++ lib.optionals stdenv.cc.isClang [
      llvmPackages.openmp
    ];

  cmakeFlags = [
    (lib.cmakeBool "MFEM_ENABLE_TESTING" finalAttrs.finalPackage.doCheck)
    (lib.cmakeBool "MFEM_ENABLE_MINIAPPS" true)
    (lib.cmakeBool "BUILD_SHARED_LIBS" (!stdenv.hostPlatform.isStatic))
    (lib.cmakeBool "MFEM_USE_MPI" true)
    (lib.cmakeBool "MFEM_USE_METIS" true)
    (lib.cmakeBool "MFEM_USE_ZLIB" true)
    (lib.cmakeBool "MFEM_USE_LAPACK" true)
    (lib.cmakeBool "BLA_PREFER_PKGCONFIG" true)
    (lib.cmakeBool "MFEM_USE_OPENMP" true)
    (lib.cmakeBool "MFEM_USE_SUITESPARSE" true)
    (lib.cmakeBool "MFEM_USE_SUPERLU" true)
    (lib.cmakeBool "MFEM_USE_MUMPS" true)
    (lib.cmakeBool "MFEM_USE_PETSC" true)
    (lib.cmakeBool "MFEM_USE_SLEPC" true)
    (lib.cmakeBool "MFEM_USE_ADIOS2" true)
    (lib.cmakeFeature "MFEM_PRECISION" precision)
    (lib.cmakeFeature "PETSC_DIR" "${petsc}")
    (lib.cmakeFeature "PETSC_ARCH" "")
    (lib.cmakeFeature "SLEPC_DIR" "${slepc}")
    (lib.cmakeFeature "SLEPC_ARCH" "")
    (lib.cmakeFeature "MUMPS_REQUIRED_PACKAGES" "")
    (lib.cmakeFeature "SuperLUDist_REQUIRED_PACKAGES" "")
  ];

  __darwinAllowLocalNetworking = true;

  preCheck = lib.optionalString stdenv.hostPlatform.isDarwin ''
    export DYLD_LIBRARY_PATH=${hypre}/lib:$DYLD_LIBRARY_PATH
  '';

  doCheck = true;

  nativeCheckInputs = [ mpiCheckPhaseHook ];

  postFixup = lib.optionalString stdenv.hostPlatform.isDarwin ''
    install_name_tool -add_rpath ${hypre}/lib $out/lib/libmfem.dylib
  '';

  meta = {
    description = "Free, lightweight, scalable C++ library for finite element methods";
    homepage = "https://mfem.org";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ qbisi ];
    platforms = lib.platforms.unix;
  };
})
