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
  siphash24,
  cachetools,
  decorator,
  mpi4py,
  h5py,
  petsc4py,
  numpy,
  packaging,
  pkgconfig,
  progress,
  pycparser,
  pytools,
  requests,
  rtree,
  scipy,
  sympy,
  firedrake-ufl,
  firedrake-fiat,
  pyadjoint-ad,
  firedrake-loopy,
  libsupermesh,

  # lint
  flake8,
  pylint,

  # doc
  sphinx,
  sphinx-autobuild,
  sphinxcontrib-bibtex,
  # not available in nixpkgs
  # sphinxcontrib-svg2pdfconverter,
  sphinxcontrib-jquery,
  bibtexparser,
  sphinxcontrib-youtube,
  numpydoc,

  # tests
  mpi,
  ipympl,
  vtk,
  # pytest-split,
  pylit,
  nbval,
  pytest,
  mpi-pytest,
  pytest-xdist,
  pytest-timeout,
  mpiCheckPhaseHook,

  # passthru.tests
  mpich,
  firedrake,
  pytestCheckHook,
}:
let
  mpi4py' = mpi4py.override { mpi = petsc4py.petscPackages.mpi; };
  h5py' = h5py.override {
    hdf5 = petsc4py.petscPackages.hdf5;
    mpi4py = mpi4py';
  };
in
buildPythonPackage rec {
  version = "0.14-unstable-2025-04-14";
  pname = "firedrake";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "firedrakeproject";
    repo = "firedrake";
    rev = "d3c02bcbf5cca0ff71b3306d7d2796ef6bbf6945";
    hash = "sha256-2AsymQj6qn9NkI320PIKh/OALV1hl20Dgyi/ij/gK+o=";
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
        'program = ["otool"]' \
        'program = ["${stdenv.cc.bintools.bintools}/bin/otool"]'
    '';

  pythonRelaxDeps = true;

  build-system = [
    writableTmpDirAsHomeHook
    setuptools
    cython
    pybind11
  ];

  buildInputs = [
    petsc4py.petscPackages.mpi
  ];

  dependencies = [
    siphash24
    decorator
    cachetools
    mpi4py'
    h5py'
    petsc4py
    numpy
    packaging
    pkgconfig
    progress
    pycparser
    pytools
    requests
    rtree
    scipy
    sympy
    firedrake-ufl
    firedrake-fiat
    pyadjoint-ad
    firedrake-loopy
    libsupermesh
  ];

  optional-dependencies = {
    dev = [
      build
      cython
      mpi-pytest
      pybind11
      pytest
      setuptools
    ];

    test = [
      vtk
      pylit
      nbval
      pytest
      mpi-pytest
      pytest-xdist
      pytest-timeout
      ipympl # needed for notebook testing
      # pytest-split  # needed for firedrake-run-split-tests
    ];

    docs = [
      sphinx
      sphinx-autobuild
      sphinxcontrib-bibtex
      # not available in nixpkgs
      # sphinxcontrib-svg2pdfconverter
      sphinxcontrib-jquery
      bibtexparser
      sphinxcontrib-youtube
      numpydoc
    ];
  };

  postInstall = ''
    rm -rf firedrake pyop2 tinyasm tsfc
  '';

  doCheck = true;

  pythonImportsCheck = [ "firedrake" ];

  nativeCheckInputs = [
    mpiCheckPhaseHook
    petsc4py.petscPackages.mpi
  ] ++ optional-dependencies.test;

  preCheck = ''
    export VIRTUAL_ENV=$HOME
  '';

  checkPhase = ''
    runHook preCheck

    make check

    runHook postCheck
  '';

  passthru.tests = {
    fullCheck = firedrake.overrideAttrs (oldAttrs: {
      nativeCheckInputs = oldAttrs ++ [ pytestCheckHook ];
      # PYOP2_CFLAGS is used to pass some badly written example tests
      env.PYOP2_CFLAGS = "-Wno-incompatible-pointer-types";
      pytestFlagsArray = [
        "tests"
      ];
      disabledTests = [
        "test_dat_illegal_name"
        "test_dat_illegal_set"
      ];
    });
    mpich = firedrake.override { petsc4py = petsc4py.override { mpi = mpich; }; };
  };

  meta = {
    homepage = "http://www.firedrakeproject.org";
    description = "Automated system for the portable solution of partial differential equations using the finite element method (FEM)";
    license = lib.licenses.lgpl3;
    maintainers = with lib.maintainers; [ qbisi ];
  };
}
