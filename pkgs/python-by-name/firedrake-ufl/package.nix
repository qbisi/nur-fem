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
  version = "2024.3.0-unstable-2025-03-25";
  pname = "firedrake-ufl";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "firedrakeproject";
    repo = "ufl";
    rev = "07d8a76efc1f8d6075fb33d8c55eff0b2999eaca";
    hash = "sha256-cJKsyB1QXf+ECkctpfyZRO0K3J53pMZwP0PdOthGp2c=";
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
    description = "Unified Form Language (firdrake fork)";
    longDescription = ''
      The Unified Form Language (UFL) is a domain specific language for declaration
      of finite element discretizations of variational forms. More precisely, it
      defines a flexible interface for choosing finite element spaces and defining
      expressions for weak forms in a notation close to mathematical notation.
    '';
    license = lib.licenses.lgpl3;
    maintainers = with lib.maintainers; [ qbisi ];
  };
}
