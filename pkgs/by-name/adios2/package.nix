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
  c-blosc2,
  hdf5-mpi,
  libpng,
  libsodium,
  pugixml,
  sqlite,
  yaml-cpp,
  zeromq,
  zfp,
  zlib,
  ucx,
  llvmPackages,
  gtest,
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
      c-blosc2
      hdf5-mpi
      libpng
      libsodium
      pugixml
      sqlite
      yaml-cpp
      zeromq
      zfp
      zlib

      # Todo: add these optional dependcies in nixpkgs.
      # sz
      # mgard
      # catalyst
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      ucx
    ]
    ++ lib.optionals stdenv.cc.isClang [
      llvmPackages.openmp
    ];

  propagatedBuildInputs = lib.optionals pythonSupport [
    python3Packages.mpi4py
    python3Packages.numpy
  ];

  cmakeFlags = [
    (lib.cmakeBool "ADIOS2_BUILD_EXAMPLES" withExamples)
    (lib.cmakeBool "BUILD_TESTING" finalAttrs.finalPackage.doCheck)
    (lib.cmakeFeature "CMAKE_INSTALL_PYTHONDIR" python3.sitePackages)
    # required for finding the generated adios2-config.cmake file
    (lib.cmakeFeature "CMAKE_PREFIX_PATH" "${placeholder "out"}")
  ];

  nativeCheckInputs = [
    gtest
  ];

  doCheck = false;

  meta = {
    homepage = "https://adios2.readthedocs.io/en/latest/";
    description = "The Adaptable Input/Output System version 2";
    license = lib.licenses.asl20;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ qbisi ];
  };
})
