{
  lib,
  stdenv,
  fetchPypi,
  fetchFromGitHub,
  buildPythonPackage,
  scikit-build-core,
  setuptools,
  nanobind,
  cmake,
  ninja,
  pkg-config,
  mpi,
  pkgs,
  numpy,
  cffi,
  mpi4py,
  petsc4py,
  slepc4py,
  fenics-basix,
  fenics-ffcx,
  fenics-ufl,
  scipy,
  matplotlib,
  pytest-xdist,
  pytestCheckHook,
  writableTmpDirAsHomeHook,
}:
let
  dolfinx = stdenv.mkDerivation (finalAttrs: {
    version = "0.9.0.post1";
    pname = "dolfinx";

    src = fetchFromGitHub {
      owner = "fenics";
      repo = "dolfinx";
      tag = "v${finalAttrs.version}";
      hash = "sha256-4IIx7vUZeDwOGVdyC2PBvfhVjrmGZeVQKAwgDYScbY0=";
    };

    preConfigure = "cd cpp";

    nativeBuildInputs = [
      cmake
      pkg-config
    ];

    buildInputs = [
      mpi
      pkgs.scotch
      pkgs.spdlog
      pkgs.pugixml
      pkgs.boost
      pkgs.hdf5-mpi
      petsc4py
      slepc4py
      fenics-basix
      fenics-ffcx
    ];

    cmakeFlags = [
      (lib.cmakeBool "DOLFINX_ENABLE_ADIOS2" false)
      (lib.cmakeBool "DOLFINX_ENABLE_PETSC" true)
      (lib.cmakeBool "DOLFIN_ENABLE_PARMETIS" false)
      (lib.cmakeBool "DOLFINX_ENABLE_SCOTCH" true)
      (lib.cmakeBool "DOLFINX_ENABLE_SLEPC" true)
      (lib.cmakeBool "DOLFINX_ENABLE_KAHIP" false)
      (lib.cmakeFeature "CMAKE_INSTALL_BINDIR" "bin")
      (lib.cmakeFeature "CMAKE_INSTALL_LIBDIR" "lib")
      (lib.cmakeFeature "CMAKE_INSTALL_INCLUDEDIR" "include")
    ];

    doCheck = true;

    meta = {
      homepage = "https://github.com/fenics/dolfinx";
      description = "Next generation FEniCS problem solving environment";
      changelog = "https://github.com/fenics/dolfinx/releases/tag/${finalAttrs.src.tag}";
      license = with lib.licenses; [
        gpl3Plus
        lgpl3Plus
      ];
      maintainers = with lib.maintainers; [ qbisi ];
    };
  });
in
buildPythonPackage rec {
  inherit (dolfinx)
    version
    src
    meta
    ;
  pname = "fenics-dolfinx";
  pyproject = true;

  postPatch = ''
    substituteInPlace python/pyproject.toml \
      --replace-fail "cffi<1.17" "cffi"
  '';

  preConfigure = "cd python";

  build-system = [
    scikit-build-core
    nanobind
    cmake
    ninja
    pkg-config
    mpi
  ];

  dontUseCmakeConfigure = true;

  buildInputs = with pkgs; [
    dolfinx
    spdlog
    pugixml
    boost
    hdf5-mpi
  ];

  dependencies = [
    numpy
    cffi
    setuptools
    mpi4py
    petsc4py
    slepc4py
    fenics-basix
    fenics-ffcx
    fenics-ufl
  ];

  postInstall = ''
    rm -rf dolfinx
  '';

  pythonImportsCheck = [
    "dolfinx"
  ];

  doCheck = false;

  nativeCheckInputs = [
    scipy
    matplotlib
    pytest-xdist
    pytestCheckHook
    writableTmpDirAsHomeHook
  ];
}
