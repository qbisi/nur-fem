{
  lib,
  stdenv,
  fetchFromGitHub,
  perl,
  cmake,
  ninja,
  gfortran,
  nlohmann_json,
  python3,
  python3Packages,
  mpi,
  bzip2,
  c-blosc2,
  hdf5-mpi,
  libpng,
  libsodium,
  paraview,
  pugixml,
  sqlite,
  yaml-cpp,
  zeromq,
  zfp,
  zlib,
  gtest,
  cudaSupport ? false,
  pythonSupport ? false,
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
    substituteInPlace cmake/install/post/generate-adios2-config.sh.in \
      --replace-fail '[ ! -d "''${PREFIX}" ]' 'true'

    patchShebangs cmake scripts testing
  '';

  nativeBuildInputs =
    [
      perl
      cmake
      ninja
      gfortran
      nlohmann_json
    ];
    # ++ lib.optionals pythonSupport [
    #   python3
    #   python3Packages.pybind11
    # ];

  buildInputs = [
    mpi
    bzip2
    c-blosc2
    hdf5-mpi
    libpng
    libsodium
    # paraview
    pugixml
    sqlite
    yaml-cpp
    zeromq
    zfp
    zlib
    # sz
    # mgard
  ];

  cmakeFlags = [
    (lib.cmakeBool "ADIOS2_USE_CUDA" cudaSupport)
    (lib.cmakeBool "ADIOS2_BUILD_EXAMPLES" withExamples)
    # (lib.cmakeFeature "CMAKE_INSTALL_BINDIR" "bin")
    # (lib.cmakeFeature "CMAKE_INSTALL_LIBDIR" "lib")
  ];

  nativeCheckInputs = [
    gtest
  ];

  doCheck = true;

  meta = {
    homepage = "https://adios2.readthedocs.io/en/latest/";
    description = "The Adaptable Input/Output System version 2";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ qbisi ];
  };
})
