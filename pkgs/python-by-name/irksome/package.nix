{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  writableTmpDirAsHomeHook,
  setuptools,
  firedrake,
  pytest-xdist,
  pytestCheckHook,
  pylit,
}:
buildPythonPackage rec {
  version = "0-unstable-2025-03-14";
  pname = "irksome";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "firedrakeproject";
    repo = "irksome";
    rev = "73967a77f31a5518e9ee9d74ad8e6351ca98ceb4";
    hash = "sha256-v+hErZPxF8IL8PEDJJgj1TLqcAeouzFgAfX8pfOrKdo=";
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
    firedrake
    pylit
  ];

  meta = {
    homepage = "https://www.firedrakeproject.org/Irksome";
    description = "Generate Runge-Kutta methods from a semi-discrete UFL form";
    license = lib.licenses.lgpl3;
    maintainers = with lib.maintainers; [ qbisi ];
  };
}
