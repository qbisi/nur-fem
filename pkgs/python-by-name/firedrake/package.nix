{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  python,

  # build-system
  writableTmpDirAsHomeHook,
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
  mpiCheckPhaseHook,

  # passthru.tests
  firedrake,
  runCommand,
}:
buildPythonPackage rec {
  version = "0-unstable-2025-04-04";
  pname = "firedrake";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "firedrakeproject";
    repo = "firedrake";
    rev = "73d63aa95d4a9f6a454254840b95367600434a5f";
    hash = "sha256-28dQmX6+Al30ZeImORjI8vwCJ1LxRK9jZIYGflqKH8U=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml --replace-fail \
      "petsc4py==3.22.2" \
      "petsc4py"
  '';

  pythonRelaxDeps = true;

  build-system = [
    writableTmpDirAsHomeHook
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
    mpi # require mpiexec
    (lib.getDev mpi) # require mpicc
    (lib.getBin glibc) # require ldd
    petsc4py.petscPackages.blas
    petsc4py.petscPackages.lapack
  ];

  postInstall = ''
    install -D ${./logo-64x64.ico} $out/${python.sitePackages}/firedrake/icons/logo-64x64.png
    rm -rf firedrake pyop2 tinyasm tsfc
  '';

  doCheck = true;

  pythonImportsCheck = [ "firedrake" ];

  nativeCheckInputs = [ mpiCheckPhaseHook ] ++ propagatedUserEnvPkgs ++ optional-dependencies.test;

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
          nativeBuildInputs =
            [
              firedrake
              mpiCheckPhaseHook
            ]
            ++ propagatedUserEnvPkgs
            ++ optional-dependencies.test;
        }
        ''
          runHook preCheck

          set +e
          export HOME="$(mktemp -d)"
          export VIRTUAL_ENV="$HOME"

          cd $src/tests
          echo "testing firedrake ..."
          pytest -n auto -m "not parallel or parallel[1]" --tb=native --timeout=480 --timeout-method=thread -o faulthandler_timeout=540 -v firedrake
          echo "testing tsfc ..."
          pytest -n auto -m "not parallel or parallel[1]" --tb=native --timeout=480 --timeout-method=thread -o faulthandler_timeout=540 -v tsfc
          echo "testing pyop2 ..."
          pytest -n auto -m "not parallel or parallel[1]" --tb=native --timeout=480 --timeout-method=thread -o faulthandler_timeout=540 -v pyop2
          mpiexec -n 2 pytest -m "parallel[2]" --tb=native --timeout=480 --timeout-method=thread -o faulthandler_timeout=540 -v pyop2
          mpiexec -n 3 pytest -m "parallel[3]" --tb=native --timeout=480 --timeout-method=thread -o faulthandler_timeout=540 -v pyop2

          runHook postCheck
        '';
  };

  meta = {
    homepage = "http://www.firedrakeproject.org";
    description = "Automated system for the portable solution of partial differential equations using the finite element method (FEM)";
    license = lib.licenses.lgpl3;
    maintainers = with lib.maintainers; [ qbisi ];
  };
}
