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
  version = "2023.0.0-unstable-2025-02-19";
  pname = "pyadjoint-ad";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "dolfin-adjoint";
    repo = "pyadjoint";
    rev = "da1f189872447564e757d1fa7ee293f8acb89bca";
    hash = "sha256-IQtPCkdjuJTkGnzY+4PIoXIEIZRieDR3b5WOFeO8M9A=";
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
