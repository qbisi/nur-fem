{
  lib,
  stdenv,
  fetchFromGitHub,
  perl,
  cmake,
  ninja,
  gfortran,
  pkg-config,
  nlohmann_json,
  python3,
  python3Packages,
  mpi,
  bzip2,
  lz4,
  c-blosc2,
  hdf5-mpi,
  libfabric,
  libpng,
  libsodium,
  pugixml,
  sqlite,
  zeromq,
  zfp,
  zlib,
  ucx,
  yaml-cpp,
  llvmPackages,
  pythonSupport ? true,
  withExamples ? false,
}:
stdenv.mkDerivation (finalAttrs: {
  version = "2.10.2";
  pname = "adios2";

  src = fetchFromGitHub {
    owner = "ornladios";
    repo = "adios2";
    tag = "v${finalAttrs.version}";
    hash = "sha256-NVyw7xoPutXeUS87jjVv1YxJnwNGZAT4QfkBLzvQbwg=";
  };

  postPatch = ''
    patchShebangs cmake scripts testing
  '';

  nativeBuildInputs =
    [
      perl
      cmake
      ninja
      gfortran
      pkg-config
      nlohmann_json
    ]
    ++ lib.optionals pythonSupport [
      python3
      python3Packages.pybind11
    ];

  buildInputs =
    [
      mpi
      bzip2
      lz4
      c-blosc2
      hdf5-mpi
      libfabric
      libpng
      libsodium
      pugixml
      sqlite
      zeromq
      zfp
      zlib
      yaml-cpp

      # Todo: add these optional dependcies in nixpkgs.
      # sz
      # mgard
      # catalyst
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      ucx
    ]
    # openmp required by zfp
    ++ lib.optionals stdenv.cc.isClang [
      llvmPackages.openmp
    ];

  propagatedBuildInputs = lib.optionals pythonSupport [
    python3Packages.mpi4py
    python3Packages.numpy
  ];

  cmakeFlags = [
    (lib.cmakeBool "ADIOS2_USE_HDF5_VOL" true)
    (lib.cmakeBool "ADIOS2_BUILD_EXAMPLES" withExamples)
    (lib.cmakeBool "BUILD_TESTING" finalAttrs.finalPackage.doCheck)
    (lib.cmakeBool "ADIOS2_USE_EXTERNAL_DEPENDENCIES" true)
    (lib.cmakeBool "ADIOS2_USE_EXTERNAL_GTEST" false)
    (lib.cmakeFeature "CMAKE_INSTALL_PREFIX" "/")
    (lib.cmakeFeature "CMAKE_INSTALL_PYTHONDIR" "${placeholder "out"}/${python3.sitePackages}")
    (lib.cmakeFeature "CMAKE_INSTALL_DATAROOTDIR" "${placeholder "out"}/share")
    (lib.cmakeFeature "CMAKE_CTEST_ARGUMENTS" "-E;'${lib.concatStringsSep "|" finalAttrs.excludedTests}'")
  ];

  # required for finding the generated adios2-config.cmake file
  env.adios2_DIR = "${placeholder "out"}/lib/cmake/adios2";

  doCheck = true;

  excludedTests = [
    # require installed adios2-config
    "Install.*"
    # fail on sandbox
    "Unit.FileTransport.FailOnEOF.Serial"
    # osc_ucx_component.c:369  Error: OSC UCX component priority set inside component query failed
    "Bindings.Fortran.BPWriteReadHeatMap6D.MPI"
    # testing/adios2/engine/bp/TestBPJoinedArray.cpp:182: Failure
    # Expected: (data[i * Ncols + j]) < ((nsteps + 1) * 1.0 + 0.9999), actual: 5.3073 vs 4.9999
    "Engine.BP.BPJoinedArray.MultiBlock.BP4.MPI"
    "Engine.BP.BPJoinedArray.MultiBlock.BP5.MPI"
    "Engine.BP.*/BPReadMultithreadedTestP.ReadFile/*.BP5.Serial"
    "Engine.BP.*/BPReadMultithreadedTestP.ReadStream/*.BP5.Serial"
  ];

  postFixUp = ''
    patchShebangs $out/bin
  '';

  meta = {
    homepage = "https://adios2.readthedocs.io/en/latest/";
    description = "The Adaptable Input/Output System version 2";
    license = lib.licenses.asl20;
    platforms = lib.platforms.unix;
    broken = stdenv.hostPlatform.isDarwin && pythonSupport;
    maintainers = with lib.maintainers; [ qbisi ];
  };
})
