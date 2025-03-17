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
  version = "0-unstable-2025-02-19";
  pname = "pyadjoint-ad";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "dolfin-adjoint";
    repo = "pyadjoint";
    rev = "dbf923e656b37333e45267da2e0264a84f160be5";
    sha256 = "sha256-UeBjOIqd0SVxqb7t+oKjnEzEWhDRAb65KBVJO1iUNTc=";
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
    # need import fenics and firedrake which are circular dependencies
    # "firedrake_adjoint"
    # "fenics_adjoint"
  ];

  # pytest require circular dependencies of firedrake and fenics 
  doCheck = false;

  meta = {
    homepage = "https://github.com/dolfin-adjoint/pyadjoint";
    description = "Operator-overloading algorithmic differentiation framework for Python";
    license = lib.licenses.lgpl3;
    maintainers = with lib.maintainers; [ qbisi ];
  };
}
