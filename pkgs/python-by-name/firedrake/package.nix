{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  python,

  # build-system
  build,
  setuptools,
  cython,
  pybind11,
  mpi,

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

  # propagatedUserEnvPkgs
  glibc,

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
  # pytest-split,
  pylit,
  nbval,
  pytest,
  mpi-pytest,
  pytest-xdist,
  pytest-timeout,
  pytestCheckHook,
  mpiCheckPhaseHook,
}:
buildPythonPackage rec {
  version = "20250218.0";
  pname = "firedrake";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "firedrakeproject";
    repo = "firedrake";
    tag = "Firedrake_${version}";
    hash = "sha256-7AYJ1fhXe36V/zrD8aYZz7V/D4G2y2nwxhJ/72in29k=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml --replace-fail \
      "decorator<=4.4.2" \
      "decorator"
  '';

  build-system = [
    setuptools
    cython
    pybind11
    mpi
  ];

  buildInputs = [
    petsc4py.petscPackages.hdf5
  ];

  dependencies = [
    siphash24
    decorator
    cachetools
    mpi4py
    h5py
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

  propagatedUserEnvPkgs = [
    mpi
    (lib.getDev mpi)
    (lib.getBin glibc)
  ];

  postInstall = ''
    install -D ${./logo-64x64.ico} $out/${python.sitePackages}/firedrake/icons/logo-64x64.png
    export HOME="$(mktemp -d)"
  '';

  #ImportError: cannot import name 'sparsity' from partially initialized modules
  pythonImportsCheck = [ "firedrake" ];

  doCheck = false;

  nativeCheckInputs = [ mpiCheckPhaseHook ] ++ propagatedUserEnvPkgs ++ optional-dependencies.test;

  installCheckPhase = ''
    runHook preInstallCheck

    export HOME=$(mktemp -d)
    cd tests
    echo "testing firedrake ..."
    pytest -n auto --tb=native --timeout=480 --timeout-method=thread -o faulthandler_timeout=540 -v firedrake
    echo "testing tsfc ..."
    pytest -n auto --tb=native --timeout=480 --timeout-method=thread -o faulthandler_timeout=540 -v tsfc
    echo "testing pyop2 ..."
    pytest -n auto -m "not parallel" --tb=native --timeout=480 --timeout-method=thread -o faulthandler_timeout=540 -v pyop2
    mpiexec -n 2 pytest -m "parallel[2]" --tb=native --timeout=480 --timeout-method=thread -o faulthandler_timeout=540 -v pyop2
    mpiexec -n 3 pytest -m "parallel[3]" --tb=native --timeout=480 --timeout-method=thread -o faulthandler_timeout=540 -v pyop2
    cd ..

    runHook postInstallCheck
  '';

  meta = {
    homepage = "http://www.firedrakeproject.org";
    description = "Automated system for the portable solution of partial differential equations using the finite element method (FEM)";
    changelog = "https://github.com/firedrakeproject/firedrake/releases/tag/${src.tag}";
    license = lib.licenses.lgpl3;
    maintainers = with lib.maintainers; [ qbisi ];
  };
}
