{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  mpi,
  trilinos,
  petsc,
  slepc,
  zlib,
  perl,
  mpiCheckPhaseHook,
  # custom options
  mpiSupport ? true,
  sse2Support ? stdenv.hostPlatform.isx86,
  avxSupport ? stdenv.hostPlatform.avxSupport,
  avx512Support ? stdenv.hostPlatform.avx512Support,
  neonSupport ? stdenv.hostPlatform.isAarch64,
}:
let
  dealiiPackages = petsc.petscPackages.overrideScope (
    final: prev: {
      inherit mpi mpiSupport;
      withMPI = mpiSupport;

      trilinos = final.callPackage trilinos.override { };
      slepc = final.callPackage slepc.override { };
    }
  );
in
stdenv.mkDerivation (finalAttrs: {
  pname = "dealii";
  version = "9.6.2";

  src = fetchFromGitHub {
    owner = "dealii";
    repo = "dealii";
    tag = "v${finalAttrs.version}";
    hash = "sha256-sIyGSEmGc2JMKwvFRkJJLROUNdLKVhPgfUx1IfjT3dI=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  cmakeFlags = [
    (lib.cmakeBool "DEAL_II_ALLOW_PLATFORM_INTROSPECTION" false)
    (lib.cmakeBool "DEAL_II_HAVE_SSE2" sse2Support)
    (lib.cmakeBool "DEAL_II_HAVE_AVX" avxSupport)
    (lib.cmakeBool "DEAL_II_HAVE_AVX512" avx512Support)
    (lib.cmakeBool "DEAL_II_HAVE_ARM_NEON" neonSupport)
    (lib.cmakeBool "DEAL_II_ALLOW_AUTODETECTION" false)
    (lib.cmakeBool "DEAL_II_WITH_HDF5" true)
    (lib.cmakeBool "DEAL_II_WITH_LAPACK" true)
    (lib.cmakeBool "DEAL_II_WITH_METIS" true)
    (lib.cmakeBool "DEAL_II_WITH_MPI" mpiSupport)
    (lib.cmakeBool "DEAL_II_WITH_P4EST" true)
    (lib.cmakeBool "DEAL_II_WITH_PETSC" true)
    (lib.cmakeBool "DEAL_II_WITH_SCALAPACK" true)
    (lib.cmakeBool "DEAL_II_WITH_SLEPC" true)
    # (lib.cmakeBool "DEAL_II_WITH_TRILINOS" true)
    (lib.cmakeBool "DEAL_II_WITH_UMFPACK" true)
    (lib.cmakeBool "DEAL_II_WITH_ZLIB" true)
    (lib.cmakeBool "BLA_PREFER_PKGCONFIG" true)
  ];

  buildInputs = [
    dealiiPackages.blas
    dealiiPackages.lapack
    dealiiPackages.metis
    dealiiPackages.hdf5
    dealiiPackages.p4est
    dealiiPackages.petsc
    dealiiPackages.scalapack
    dealiiPackages.slepc
    # dealiiPackages.trilinos
    dealiiPackages.suitesparse
    zlib
  ] ++ lib.optional mpiSupport mpi;

  doCheck = true;

  __darwinAllowLocalNetworking = mpiSupport;

  nativeCheckInputs = [
    perl
  ] ++ lib.optional mpiSupport mpiCheckPhaseHook;

  meta = {
    description = "Finite Element Differential Equations Analysis Library";
    homepage = "https://www.dealii.org/";
    downloadPage = "https://github.com/dealii/dealii";
    changelog = "https://github.com/dealii/dealii/releases/tag/v${finalAttrs.version}";
    license = with lib.licenses; [ lgpl2Plus ];
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ qbisi ];
  };
})
