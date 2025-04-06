{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  writableTmpDirAsHomeHook,
  setuptools,
  firedrake,
  pytest-xdist,
  pytestCheckHook,
  mpiCheckPhaseHook,
  pylit,
  vtk,
}:
buildPythonPackage rec {
  version = "0-unstable-2025-04-01";
  pname = "irksome";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "firedrakeproject";
    repo = "irksome";
    rev = "6190331e01990dc9793448ea611b80e41a9b4bfd";
    hash = "sha256-++z+RTIM2mdi5NdaD6XR2Bh0HkuBuOYBotGtdZn/J0s=";
  };

  build-system = [
    setuptools
    writableTmpDirAsHomeHook
  ];

  postInstall = ''
    export VIRTUAL_ENV="$HOME"
  '';

  pythonImportsCheck = [
    "irksome"
  ];

  nativeCheckInputs = [
    pytest-xdist
    pytestCheckHook
    mpiCheckPhaseHook
    firedrake
    pylit
    vtk
  ];

  meta = {
    homepage = "https://www.firedrakeproject.org/Irksome";
    description = "Generate Runge-Kutta methods from a semi-discrete UFL form";
    license = lib.licenses.lgpl3;
    maintainers = with lib.maintainers; [ qbisi ];
  };
}
