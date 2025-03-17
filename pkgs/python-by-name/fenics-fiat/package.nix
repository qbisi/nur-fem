{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  numpy,
  scipy,
  sympy,
  recursivenodes,
  symengine,
  fenics-ufl,
  pytestCheckHook,
}:

buildPythonPackage rec {
  version = "20250113.0";
  pname = "fenics-fiat";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "firedrakeproject";
    repo = "fiat";
    tag = "Firedrake_${version}";
    sha256 = "sha256-wvqKnNBAjkG7Qo2XeeMRVOCoHCdIGM6N51ULbyBZBoo=";
  };

  build-system = [ setuptools ];

  dependencies = [
    numpy
    scipy
    sympy
    recursivenodes
    fenics-ufl
    symengine
  ];

  pythonImportsCheck = [ "FIAT" ];

  nativeCheckInputs = [ pytestCheckHook ];

  # Todo: download externel data for regression tests
  disabledTestPaths = [
    "test/FIAT/regression/"
  ];

  meta = {
    homepage = "https://github.com/firedrakeproject/fiat";
    description = "Copy of upstream FIAT for use with Firedrake";
    changelog = "https://github.com/firedrakeproject/fiat/releases/tag/${src.tag}";
    license = lib.licenses.lgpl3;
    maintainers = with lib.maintainers; [ qbisi ];
  };
}
