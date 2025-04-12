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
  loopy,
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
  firedrake,
  runCommand,
  pytestCheckHook,
}:
buildPythonPackage rec {
  version = "0.14-unstable-2025-04-04";
  pname = "firedrake";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "firedrakeproject";
    repo = "firedrake";
    rev = "73d63aa95d4a9f6a454254840b95367600434a5f";
    hash = "sha256-28dQmX6+Al30ZeImORjI8vwCJ1LxRK9jZIYGflqKH8U=";
  };

  postPatch =
    ''
      substituteInPlace pyproject.toml --replace-fail \
        "petsc4py==3.22.2" \
        "petsc4py"
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

  dependencies = [
    siphash24
    decorator
    cachetools
    mpi4py
    (h5py.override { hdf5 = petsc4py.petscPackages.hdf5; })
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
    loopy
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

  nativeCheckInputs = [ mpiCheckPhaseHook ] ++ optional-dependencies.test;

  installCheckPhase = ''
    runHook preCheck

    make check

    runHook postCheck
  '';

  passthru.tests = {
    fullCheck =
      runCommand "firedrake-full-check"
        {
          inherit src;
          nativeBuildInputs = [
            firedrake
            pytestCheckHook
            mpiCheckPhaseHook
          ] ++ optional-dependencies.test;
          # PYOP2_CFLAGS is used to pass some badly written example tests
          env.PYOP2_CFLAGS = toString [
            "-Wno-incompatible-pointer-types"
          ];

          pytestFlags = [
            "-n $NIX_BUILD_CORES"
            "--timeout=480"
            "--timeout-method=thread"
            "-o faulthandler_timeout=540"
          ];

          disabledTests = [
            "test_dat_illegal_name"
            "test_dat_illegal_set"
            "parallel"
          ];
        }
        ''
          runPhase unpackPhase

          substituteInPlace tests/pyop2/test_callables.py \
            --replace-fail "-llapack" "-L${lib.getLib petsc4py.petscPackages.lapack}/lib -llapack"

          mkdir -p $out
          export TMPDIR=$out
          export HOME=$TMPDIR
          export VIRTUAL_ENV=$HOME
          cd tests

          pytestCheckPhase
        '';
  };

  meta = {
    homepage = "http://www.firedrakeproject.org";
    description = "Automated system for the portable solution of partial differential equations using the finite element method (FEM)";
    license = lib.licenses.lgpl3;
    maintainers = with lib.maintainers; [ qbisi ];
  };
}
