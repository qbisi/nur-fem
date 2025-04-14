{
  lib,
  fetchFromGitHub,
  fetchpatch,
  buildPythonPackage,
  setuptools,
  mpi4py,
  pytest,
  pytestCheckHook,
  mpiCheckPhaseHook,
}:

buildPythonPackage rec {
  version = "2025.4.0";
  pname = "mpi-pytest";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "firedrakeproject";
    repo = "mpi-pytest";
    tag = "v${version}";
    hash = "sha256-r9UB5H+qAJc6k2SVAiOCI2yRDLNv2zKRmfrAan+cX9I=";
  };

  postPatch = lib.optionalString (mpi4py.mpi.pname == "openmpi") ''
    substituteInPlace pytest_mpi/plugin.py \
      --replace-fail '"-genv", CHILD_PROCESS_FLAG, "1"' '"-x", f"{CHILD_PROCESS_FLAG}=1"'
  '';

  build-system = [
    setuptools
  ];

  dependencies = [
    mpi4py
    pytest
  ];

  pythonImportsCheck = [
    "pytest_mpi"
  ];

  nativeCheckInputs = [
    pytestCheckHook
    mpiCheckPhaseHook
    mpi4py.mpi
  ];

  meta = {
    homepage = "https://github.com/firedrakeproject/mpi-pytest";
    description = "Pytest plugin that lets you run tests in parallel with MPI";
    changelog = "https://github.com/firedrakeproject/mpi-pytest/releases/tag/${src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ qbisi ];
  };
}
