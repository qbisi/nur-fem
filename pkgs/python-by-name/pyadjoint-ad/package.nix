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
  pname = "pyadjoint-ad";
  version = "2025.04.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "dolfin-adjoint";
    repo = "pyadjoint";
    tag = version;
    hash = "sha256-S9A0qCatnnLuOkqWsEC4tjVY1HZqqi2T5iXu+WUoN24=";
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
