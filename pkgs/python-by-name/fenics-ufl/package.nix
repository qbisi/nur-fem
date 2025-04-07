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
  version = "2024.2.0";
  pname = "fenics-ufl";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "fenics";
    repo = "ufl";
    tag = version;
    hash = "sha256-YKLTXkN9cIKR545/JRN7zA7dNoVZEVIyO+JaL1V5ajU=";
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
    homepage = "https://github.com/fenics/ufl";
    description = "Unified Form Language";
    longDescription = ''
      The Unified Form Language (UFL) is a domain specific language for declaration
      of finite element discretizations of variational forms. More precisely, it
      defines a flexible interface for choosing finite element spaces and defining
      expressions for weak forms in a notation close to mathematical notation.
    '';
    changelog = "https://github.com/fenics/ufl/releases/tag/${src.tag}";
    license = with lib.licenses; [
      gpl3Plus
      lgpl3Plus
    ];
    maintainers = with lib.maintainers; [ qbisi ];
  };
}
