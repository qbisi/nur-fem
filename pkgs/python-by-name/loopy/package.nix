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
  version = "20250218.0";
  name = "firedrake-loopy";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "firedrakeproject";
    repo = "loopy";
    tag = "Firedrake_${version}";
    sha256 = "sha256-2DaRhSXnvmjcRm1YNKn6sj6iZAfQCRLbIr1naKGb0kw=";
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
