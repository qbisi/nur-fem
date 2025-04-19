{
  stdenv,
  lib,
  fetchurl,
  perl,
  gfortran,
  automake,
  autoconf,
  openssh,
  hwloc,
  python3,
  darwin,
  # either libfabric or ucx work for ch4backend on linux. On darwin, neither of
  # these libraries currently build so this argument is ignored on Darwin.
  ch4backend ? libfabric,
  ucx,
  libfabric,
  # Process managers to build (`--with-pm`),
  # cf. https://github.com/pmodels/mpich/blob/b80a6d7c24defe7cdf6c57c52430f8075a0a41d6/README.vin#L562-L586
  withPm ? [
    "hydra"
    "gforker"
  ],
  pmix,
  # PMIX support is likely incompatible with process managers (`--with-pm`)
  # https://github.com/NixOS/nixpkgs/pull/274804#discussion_r1432601476
  pmixSupport ? false,
}:

let
  withPmStr = if withPm != [ ] then builtins.concatStringsSep ":" withPm else "no";
in

assert (ch4backend.pname == "ucx" || ch4backend.pname == "libfabric");

stdenv.mkDerivation rec {
  pname = "mpich";
  version = "4.3.0";

  src = fetchurl {
    url = "https://www.mpich.org/static/downloads/${version}/mpich-${version}.tar.gz";
    hash = "sha256-XgQTKYStg8q5zFP3YHLSte9abSSwqf+QR6j/lhIbzGM=";
  };

  patches = [
    # Disables ROMIO test which was enabled in
    # https://github.com/pmodels/mpich/commit/09686f45d77b7739f7aef4c2c6ef4c3060946595
    # The test searches for mpicc in $out/bin, which is not yet present in the checkPhase
    # Moreover it fails one test.
    ./disable-romio-tests.patch
  ];

  outputs = [
    "out"
    "doc"
    "man"
  ];

  configureFlags =
    [
      "--enable-shared"
      "--with-pm=${withPmStr}"
    ]
    ++ lib.optionals (lib.versionAtLeast gfortran.version "10") [
      "FFLAGS=-fallow-argument-mismatch" # https://github.com/pmodels/mpich/issues/4300
      "FCFLAGS=-fallow-argument-mismatch"
    ]
    ++ lib.optionals pmixSupport [
      "--with-pmix"
    ];

  enableParallelBuilding = true;

  nativeBuildInputs = [
    gfortran
    python3
    autoconf
    automake
  ];
  buildInputs =
    [
      perl
      openssh
      hwloc
    ]
    ++ lib.optional (!stdenv.hostPlatform.isDarwin) ch4backend
    ++ lib.optional pmixSupport pmix
    ++ lib.optional stdenv.hostPlatform.isDarwin darwin.apple_sdk.frameworks.Foundation;

  # test_double_serializer.test fails on darwin
  doCheck = !stdenv.hostPlatform.isDarwin;

  # Ensure the default compilers are the ones mpich was built with
  preFixup = ''
    substituteInPlace $out/bin/mpicc \
      --replace-fail "CC=\"$CC\"" "CC=\"${stdenv.cc}/bin/$CC\""
    substituteInPlace $out/bin/mpicxx \
      --replace-fail "CXX=\"$CXX\"" "CXX=\"${stdenv.cc}/bin/$CXX\""
    substituteInPlace $out/bin/mpifort \
      --replace-fail "FC=\"$FC\"" "FC=\"${gfortran}/bin/$FC\""
  '';

  meta = {
    # As far as we know, --with-pmix silently disables all of `--with-pm`
    broken = pmixSupport && withPm != [ ];

    description = "Implementation of the Message Passing Interface (MPI) standard";

    longDescription = ''
      MPICH2 is a free high-performance and portable implementation of
      the Message Passing Interface (MPI) standard, both version 1 and
      version 2.
    '';
    homepage = "http://www.mcs.anl.gov/mpi/mpich2/";
    license = {
      url = "http://git.mpich.org/mpich.git/blob/a385d6d0d55e83c3709ae851967ce613e892cd21:/COPYRIGHT";
      fullName = "MPICH license (permissive)";
    };
    maintainers = [ lib.maintainers.markuskowa ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
