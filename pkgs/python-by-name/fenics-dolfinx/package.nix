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
  spdlog,
  pugixml,
  boost,
  numpy,
  cffi,
  mpi4py,
  petsc4py,
  slepc4py,
  fenics-basix,
  fenics-ffcx,
  fenics-ufl,
  adios2,
  kahip,
  scipy,
  matplotlib,
  pytest-xdist,
  pytestCheckHook,
  writableTmpDirAsHomeHook,
  withParmetis ? false,
  fenics-dolfinx,

  # passthru.tests
  mpich,
}:
assert petsc4py.mpiSupport;
let
  mpi4py' = (mpi4py.override { mpi = petsc4py.petscPackages.mpi; });
  slepc4py' = slepc4py.override {
    petsc = petsc4py;
    mpi = petsc4py.petscPackages.mpi;
  };
  adios2' = adios2.override {
    mpi = petsc4py.petscPackages.mpi;
    hdf5-mpi = petsc4py.petscPackages.hdf5;
  };
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
      adios2'
      kahip
      spdlog
      pugixml
      boost
      petsc4py.petscPackages.mpi
      petsc4py.petscPackages.scotch
      petsc4py.petscPackages.hdf5
      petsc4py
      slepc4py'
      fenics-basix
      fenics-ffcx
    ] ++ lib.optional withParmetis petsc4py.petscPackages.parmetis;

    cmakeFlags = [
      (lib.cmakeBool "DOLFINX_ENABLE_ADIOS2" true)
      (lib.cmakeBool "DOLFINX_ENABLE_PETSC" true)
      (lib.cmakeBool "DOLFIN_ENABLE_PARMETIS" withParmetis)
      (lib.cmakeBool "DOLFINX_ENABLE_SCOTCH" true)
      (lib.cmakeBool "DOLFINX_ENABLE_SLEPC" true)
      (lib.cmakeBool "DOLFINX_ENABLE_KAHIP" true)
      (lib.cmakeFeature "CMAKE_INSTALL_BINDIR" "bin")
      (lib.cmakeFeature "CMAKE_INSTALL_LIBDIR" "lib")
      (lib.cmakeFeature "CMAKE_INSTALL_INCLUDEDIR" "include")
    ];

    meta = {
      homepage = "https://github.com/fenics/dolfinx";
      description = "Next generation FEniCS problem solving environment";
      changelog = "https://github.com/fenics/dolfinx/releases/tag/${finalAttrs.src.tag}";
      license = with lib.licenses; [
        gpl3Plus
        lgpl3Plus
      ];
      platforms = lib.platforms.unix;
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

  pythonRelaxDeps = [ "cffi" ];

  preConfigure = "cd python";

  build-system = [
    scikit-build-core
    nanobind
    cmake
    ninja
    pkg-config
    petsc4py.petscPackages.mpi
  ];

  dontUseCmakeConfigure = true;

  buildInputs = [
    dolfinx
    spdlog
    pugixml
    boost
    petsc4py.petscPackages.hdf5
  ];

  dependencies = [
    numpy
    cffi
    setuptools
    mpi4py'
    petsc4py
    slepc4py'
    fenics-basix
    fenics-ffcx
    fenics-ufl
    adios2'
    kahip
  ];

  doCheck = true;

  nativeCheckInputs = [
    scipy
    matplotlib
    pytest-xdist
    pytestCheckHook
    writableTmpDirAsHomeHook
  ];

  preCheck = ''
    rm -rf dolfinx
  '';

  pythonImportsCheck = [
    "dolfinx"
  ];

  disabledTests = [
    # require legacy cffi
    "test_cffi_expression"
    "test_hexahedron_mesh"
    # might fail with pytest-xdist
    "interpolation_non_affine_nonmatching_maps"
  ];

  passthru = {
    tests = {
      complex = fenics-dolfinx.override {
        petsc4py = petsc4py.override { scalarType = "complex"; };
      };
      # mpich = fenics-dolfinx.override {
      #   petsc4py = petsc4py.override { mpi = mpich; };
      # };
      fullDeps = fenics-dolfinx.override {
        petsc4py = petsc4py.override { withFullDeps = true; };
        withParmetis = true;
      };
    };
  };
}
