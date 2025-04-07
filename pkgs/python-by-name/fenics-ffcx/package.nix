{
  lib,
  stdenv,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  numpy,
  cffi,
  fenics-ufl,
  fenics-basix,
  sympy,
  numba,
  pygraphviz,
  pytest-xdist,
  pytestCheckHook,
}:

buildPythonPackage rec {
  version = "0.9.0";
  pname = "fenics-ffcx";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "fenics";
    repo = "ffcx";
    tag = "v${version}";
    hash = "sha256-eAV//RLbrxyhqgbZ2DiR7qML7xfgPn0/Seh+2no0x8w=";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    numpy
    cffi
    fenics-ufl
    fenics-basix
  ];

  pythonImportsCheck = [
    "ffcx"
  ];

  preCheck = ''
    export PATH=$out/bin:$PATH
  '';

  nativeCheckInputs = [
    sympy
    numba
    pygraphviz
    pytest-xdist
    pytestCheckHook
  ];

  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.hostPlatform.isDarwin "-Wno-error=unused-command-line-argument";

  meta = {
    homepage = "https://github.com/fenics/ffcx";
    description = "Next generation FEniCS Form Compiler for finite element forms";
    changelog = "https://github.com/fenics/ffcx/releases/tag/${src.tag}";
    license = with lib.licenses; [
      gpl3Plus
      lgpl3Plus
    ];
    maintainers = with lib.maintainers; [ qbisi ];
  };
}
