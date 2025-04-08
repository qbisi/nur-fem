{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  scipy,
  checkpoint-schedules,
  pytestCheckHook,
}:

buildPythonPackage rec {
  version = "2023.0.0-unstable-2025-03-28";
  pname = "pyadjoint-ad";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "dolfin-adjoint";
    repo = "pyadjoint";
    rev = "0b1348021fb3bc69504e3e7ec4f90f21ba1b3822";
    hash = "sha256-r59y77aVyRfzBE2vpwJIMj2inDkAB+vP4ZAnuuKe83I=";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    scipy
    checkpoint-schedules
  ];

  pythonImportsCheck = [
    "pyadjoint"
    "numpy_adjoint"
    "pyadjoint.optimization"
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  pytestFlagsArray = [
    "tests/pyadjoint"
  ];

  meta = {
    homepage = "https://github.com/dolfin-adjoint/pyadjoint";
    description = "Operator-overloading algorithmic differentiation framework for Python";
    license = lib.licenses.lgpl3;
    maintainers = with lib.maintainers; [ qbisi ];
  };
}
