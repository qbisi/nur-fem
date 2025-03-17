{
  lib,
  fetchFromGitHub,
  fetchpatch,
  buildPythonPackage,
  setuptools,
  mpi4py,
  mpi,
  pytest,
  pytestCheckHook,
  mpiCheckPhaseHook,
}:

buildPythonPackage rec {
  version = "2025.2.0";
  pname = "mpi-pytest";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "firedrakeproject";
    repo = "mpi-pytest";
    tag = "v${version}";
    hash = "sha256-8VRzLK5RrRgmdkBFLAcG2Ehf/4qKpj1j4FymfmGgTZg=";
  };

  patches = [
    # This commit added some basic test examples
    (fetchpatch {
      name = "changing-to-boolea-argument";
      url = "https://github.com/firedrakeproject/mpi-pytest/commit/b94617b428ce33df85e9ea5ce8bed1e0bf295a34.patch";
      hash = "sha256-nwaA6mB5AKcEbXte0TYp7hthnzjotW+ujFJ224A1Tvg=";
    })
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    mpi4py
    pytest
  ];

  propagatedUserEnvPkgs = [
    mpi
  ];

  pythonImportsCheck = [
    "pytest_mpi"
  ];

  nativeCheckInputs = [
    pytestCheckHook
    mpiCheckPhaseHook
    mpi
  ];

  pytestCheckPhase = ''
    pytest -m "not parallel or parallel[1]"
    mpiexec -n 2 pytest -m "parallel[2]"
    mpiexec -n 3 pytest -m "parallel[3]"
  '';

  meta = {
    homepage = "https://github.com/firedrakeproject/mpi-pytest";
    description = "Pytest plugin that lets you run tests in parallel with MPI";
    changelog = "https://github.com/firedrakeproject/mpi-pytest/releases/tag/${src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ qbisi ];
  };
}
