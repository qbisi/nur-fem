{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  wheel,
  setuptools,
  numpy,
  pytestCheckHook,
}:

buildPythonPackage rec {
  version = "20250218.0";
  pname = "fenics-ufl";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "firedrakeproject";
    repo = "ufl";
    tag = "Firedrake_${version}";
    sha256 = "sha256-qIoXyRoPLhq1teqKhdDv1HUitVz9JfIwxJMpAXteozc=";
  };

  build-system = [
    wheel
    setuptools
  ];

  dependencies = [
    numpy
  ];

  pythonImportsCheck = [
    "ufl"
    "ufl.algorithms"
    "ufl.core"
    "ufl.corealg"
    "ufl.formatting"
    "ufl.utils"
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  meta = {
    homepage = "https://github.com/firedrakeproject/ufl";
    description = "Copy of upstream UFL for use with Firedrake";
    changelog = "https://github.com/firedrakeproject/ufl/releases/tag/${src.tag}";
    license = lib.licenses.lgpl3;
    maintainers = with lib.maintainers; [ qbisi ];
  };
}
