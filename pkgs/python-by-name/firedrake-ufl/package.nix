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
  pname = "firedrake-ufl";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "firedrakeproject";
    repo = "ufl";
    tag = "Firedrake_${version}";
    hash = "sha256-qIoXyRoPLhq1teqKhdDv1HUitVz9JfIwxJMpAXteozc=";
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
    changelog = "https://github.com/firedrakeproject/ufl/releases/tag/${src.tag}";
    license = lib.licenses.lgpl3;
    maintainers = with lib.maintainers; [ qbisi ];
  };
}
