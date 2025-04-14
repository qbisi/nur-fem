{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  constantdict,
  codepy,
  cgen,
  colorama,
  genpy,
  islpy,
  mako,
  numpy,
  pymbolic,
  pyopencl,
  pytools,
  typing-extensions,
  pytestCheckHook,
}:

buildPythonPackage rec {
  version = "2024.1-unstable-2025-02-05";
  name = "firedrake-loopy";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "firedrakeproject";
    repo = "loopy";
    rev = "27aead574b5188de8e0d98518c93f1863951fc4b";
    hash = "sha256-2DaRhSXnvmjcRm1YNKn6sj6iZAfQCRLbIr1naKGb0kw=";
    fetchSubmodules = true; # submodule at `loopy/target/c/compyte`
  };

  build-system = [
    hatchling
  ];

  dependencies = [
    constantdict
    codepy
    cgen
    colorama
    genpy
    islpy
    mako
    numpy
    pymbolic
    pyopencl
    pytools
    typing-extensions
  ];

  postConfigure = ''
    export HOME=$(mktemp -d)
  '';

  pythonImportsCheck = [ "loopy" ];

  # pyopencl._cl.LogicError: clGetPlatformIDs failed: PLATFORM_NOT_FOUND_KHR
  doCheck = false;

  nativeCheckInputs = [ pytestCheckHook ];

  meta = {
    homepage = "https://github.com/firedrakeproject/loopy";
    description = "Copy of upstream loopy for use with Firedrake";
    changelog = "https://github.com/firedrakeproject/loopy/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ qbisi ];
  };
}
