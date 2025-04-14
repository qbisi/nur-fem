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
  version = "0.14-unstable-2025-04-11";
  pname = "firedrake-ufl";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "firedrakeproject";
    repo = "ufl";
    rev = "9f3aca45ddd53c3d1575e96612eece7a714b7d41";
    hash = "sha256-C/Y7oekeBMLF4LwQHL9icPCxZq1IrkiFt4XUL5mmKpU=";
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
