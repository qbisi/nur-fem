{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  scikit-build-core,
  nanobind,
  cmake,
  ninja,
  blas,
  numpy,
  sympy,
  scipy,
  matplotlib,
  fenics-ufl,
  pytest-xdist,
  pytestCheckHook,
}:

buildPythonPackage rec {
  version = "0.9.0";
  pname = "fenics-basix";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "fenics";
    repo = "basix";
    tag = "v${version}";
    hash = "sha256-jLQMDt6zdl+oixd5Qevn4bvxBsXpTNcbH2Os6TC9sRQ=";
  };

  dontUseCmakeConfigure = true;

  build-system = [
    scikit-build-core
    nanobind
    cmake
    ninja
  ];

  dependencies = [
    blas
    numpy
  ];

  pythonImportsCheck = [
    "basix"
  ];

  nativeCheckInputs = [
    sympy
    scipy
    matplotlib
    fenics-ufl
    pytest-xdist
    pytestCheckHook
  ];

  meta = {
    homepage = "https://github.com/fenics/basix";
    description = "FEniCSx finite element basis evaluation library";
    changelog = "https://github.com/fenics/basix/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ qbisi ];
  };
}
