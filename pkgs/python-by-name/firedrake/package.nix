{
  lib,
  glibc,
  stdenv,
  buildPythonPackage,
  fetchFromGitHub,
  python,

  # build-system
  writableTmpDirAsHomeHook,
  build,
  setuptools,
  cython,
  pybind11,

  # dependencies
  decorator,
  cachetools,
  mpi4py,
  fenics-ufl,
  firedrake-fiat,
  h5py,
  libsupermesh,
  loopy,
  petsc4py,
  numpy,
  packaging,
  pkgconfig,
  progress,
  pyadjoint-ad,
  pycparser,
  pytools,
  requests,
  rtree,
  scipy,
  sympy,
  islpy,

  # tests
  mpi-pytest,
  mpiCheckPhaseHook,
  pytestCheckHook,
}:
let
  mpi4py' = mpi4py.override { mpi = petsc4py.petscPackages.mpi; };
  h5py' = h5py.override {
    hdf5 = petsc4py.petscPackages.hdf5;
    mpi4py = mpi4py';
  };
  mpi-pytest' = mpi-pytest.override { mpi4py = mpi4py'; };
in
buildPythonPackage rec {
  pname = "firedrake";
  version = "2025.4.0.post0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "firedrakeproject";
    repo = "firedrake";
    tag = version;
    hash = "sha256-wQOS4v/YkIwXdQq6JMvRbmyhnzvx6wj0O6aszNa5ZMw=";
  };

  postPatch =
    ''
      substituteInPlace pyproject.toml --replace-fail \
        "petsc4py==3.23.0" \
        "petsc4py"

      substituteInPlace tests/pyop2/test_callables.py \
        --replace-fail "-llapack" "-L${lib.getLib petsc4py.petscPackages.lapack}/lib -llapack"
    ''
    + lib.optionalString stdenv.hostPlatform.isLinux ''
      substituteInPlace firedrake/petsc.py --replace-fail \
        'program = ["ldd"]' \
        'program = ["${lib.getBin glibc}/bin/ldd"]'
    ''
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      substituteInPlace firedrake/petsc.py --replace-fail \
        'program = ["otool"' \
        'program = ["${stdenv.cc.bintools.bintools}/bin/otool"'
    '';

  pythonRelaxDeps = [
    "decorator"
  ];

  build-system = [
    cython
    libsupermesh
    mpi4py
    numpy
    pkgconfig
    pybind11
    setuptools
    petsc4py
    rtree
  ];

  nativeBuildInputs = [
    petsc4py.petscPackages.mpi
  ];

  dependencies = [
    decorator
    cachetools
    mpi4py'
    fenics-ufl
    firedrake-fiat
    h5py'
    libsupermesh
    loopy
    petsc4py
    numpy
    packaging
    pkgconfig
    progress
    pyadjoint-ad
    pycparser
    pytools
    requests
    rtree
    scipy
    sympy
  ] ++ pytools.optional-dependencies.siphash;

  postFixup = lib.optionalString stdenv.hostPlatform.isDarwin ''
    install_name_tool -add_rpath ${libsupermesh}/${python.sitePackages}/libsupermesh/lib \
      $out/${python.sitePackages}/firedrake/cython/supermeshimpl.cpython-*-darwin.so
  '';

  doCheck = true;

  pythonImportsCheck = [ "firedrake" ];

  nativeCheckInputs = [
    mpi-pytest'
    pytestCheckHook
    mpiCheckPhaseHook
    writableTmpDirAsHomeHook
  ];

  preCheck = ''
    rm -rf firedrake pyop2 tinyasm tsfc
    export VIRTUAL_ENV=$HOME
  '';

  checkPhase = ''
    runHook preCheck

    make check

    runHook postCheck
  '';

  meta = {
    homepage = "https://www.firedrakeproject.org";
    downloadPage = "https://github.com/firedrakeproject/firedrake";
    description = "Automated system for the portable solution of partial differential equations using the finite element method";
    license = with lib.licenses; [
      bsd3
      lgpl3Plus
    ];
    maintainers = with lib.maintainers; [ qbisi ];
  };
}
