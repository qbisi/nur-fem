{
  lib,
  stdenv,
  fetchurl,
  fetchpatch2,
  autoconf,
  automake,
  libtool,
  pkg-config,
  metis,
  zlib,
  jansson,
  mpi,
  mpiCheckPhaseHook,
  static ? stdenv.hostPlatform.isStatic,
  debug ? false,
  withMetis ? false,
  mpiSupport ? true,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "p4est";
  version = "2.8.7";
  __structuredAttrs = true;

  # use the official tarball releases provided on p4est.org or p4est.github.io.
  src = fetchurl {
    url = "https://p4est.github.io/release/p4est-${finalAttrs.version}.tar.gz";
    hash = "sha256-Ch6RLzUpmZym1i/uM11R8ktWULWG6VoD7znr9zk21/Q=";
  };

  nativeBuildInputs = [
    autoconf
    automake
    libtool
    pkg-config
  ] ++ lib.optional mpiSupport mpi;

  buildInputs = [
    metis
    zlib
    jansson
  ];

  configureFlags =
    [
      "CFLAGS=-O2"
      "LDFLAGS=-lm"
      "--enable-pthread=-pthread"
    ]
    ++ lib.optionals mpiSupport [
      "--with-mpi"
      "CC=mpicc"
      "CXX=mpicxx"
      "FC=mpif90"
    ]
    ++ lib.optionals static "--enable-shared=no"
    ++ lib.optional (!static) "--enable-static=no"
    ++ lib.optional debug "--enable-debug"
    ++ lib.optional withMetis "--with-metis";

  meta = {
    description = "Parallel AMR on Forests of Octrees";
    longDescription = ''
      The p4est software library provides algorithms for parallel AMR.
      AMR refers to Adaptive Mesh Refinement, a technique in scientific
      computing to cover the domain of a simulation with an adaptive mesh.
    '';
    homepage = "https://www.p4est.org/";
    downloadPage = "https://github.com/cburstedde/p4est.git";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib; [
      cburstedde
      qbisi
    ];
  };
})
