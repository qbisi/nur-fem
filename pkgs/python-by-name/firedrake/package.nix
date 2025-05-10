{
  lib,
  stdenv,
  buildPythonPackage,
  fetchFromGitHub,
  python,
  glibc,
  gnumake,
  parallel,

  # build-system
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
  matplotlib,
  pytest,
  pytest-split,

  # tests
  mpi-pytest,
  mpiCheckPhaseHook,
  writableTmpDirAsHomeHook,

  # fullCheck
  vtk,
  pylit,
  nbval,
  ipympl,
  pytest-xdist,
  pytestCheckHook,
}:
let
  mpi4py' = mpi4py.override { mpi = petsc4py.petscPackages.mpi; };
  h5py' = h5py.override {
    hdf5 = petsc4py.petscPackages.hdf5;
    mpi4py = mpi4py';
  };
  mpi-pytest' = mpi-pytest.override { mpi4py = mpi4py'; };
  self = buildPythonPackage rec {
    pname = "firedrake";
    version = "2025.4.0.post0";
    pyproject = true;

    src = fetchFromGitHub {
      owner = "firedrakeproject";
      repo = "firedrake";
      tag = version;
      hash = "sha256-wQOS4v/YkIwXdQq6JMvRbmyhnzvx6wj0O6aszNa5ZMw=";
    };

    patches = [
      ./fix-firedrake-check-in-bdist.patch
      ./move-spydump-to-script-files.patch
    ];

    postPatch =
      ''
        patchShebangs scripts

        # relax build-dependency petsc4py
        substituteInPlace pyproject.toml --replace-fail \
          "petsc4py==3.23.0" "petsc4py"

        # firedrake-status does not make sense in our binary distribution
        sed '/^firedrake-status/d' pyproject.toml

        substituteInPlace scripts/firedrake-run-split-tests \
          --replace-fail "parallel --line-buffer --tag" "${parallel}/bin/parallel --line-buffer --tag"

        substituteInPlace  firedrake/_check/__init__.py \
          --replace-fail "make" "${gnumake}/bin/make"
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

    dependencies =
      [
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
        # required by firedrake-run-split-tests
        pytest
        pytest-split
        # required by spydump
        matplotlib
      ]
      ++ pytools.optional-dependencies.siphash
      ++ lib.optional stdenv.hostPlatform.isDarwin islpy;

    postFixup = lib.optionalString stdenv.hostPlatform.isDarwin ''
      install_name_tool -add_rpath ${libsupermesh}/${python.sitePackages}/libsupermesh/lib \
        $out/${python.sitePackages}/firedrake/cython/supermeshimpl.cpython-*-darwin.so
    '';

    doCheck = true;

    pythonImportsCheck = [ "firedrake" ];

    nativeCheckInputs = [
      mpi-pytest'
      mpiCheckPhaseHook
      writableTmpDirAsHomeHook
    ];

    preCheck = ''
      rm -rf firedrake pyop2 tinyasm tsfc
    '';

    # run official smoke tests
    checkPhase = ''
      runHook preCheck

      make check

      runHook postCheck
    '';

    passthru.tests = {
      fullCheck = buildPythonPackage {
        pname = "${pname}-fullCheck";
        inherit
          src
          version
          preCheck
          ;
        format = "other";

        __darwinAllowLocalNetworking = true;

        dontBuild = true;
        dontInstall = true;

        nativeCheckInputs = [
          self
          vtk
          pylit
          nbval
          ipympl
          pytest-xdist
          mpi-pytest'
          pytestCheckHook
          mpiCheckPhaseHook
          writableTmpDirAsHomeHook
        ];

        buildInputs = [ petsc4py.petscPackages.lapack ];

        # PYOP2_CFLAGS is used to compile some legacy c code in tests kernel.
        env.PYOP2_CFLAGS = "-Wno-incompatible-pointer-types";

        pytestFlagsArray = [
          "tests"
        ];

        disabledTests = [
          # require decorator<=4.4.2
          "test_dat_illegal_name"
          "test_dat_illegal_set"
        ];
      };
    };

    meta = {
      homepage = "https://www.firedrakeproject.org";
      downloadPage = "https://github.com/firedrakeproject/firedrake";
      description = "Automated Finite Element System";
      license = with lib.licenses; [
        bsd3
        lgpl3Plus
      ];
      maintainers = with lib.maintainers; [ qbisi ];
    };
  };
in
self
