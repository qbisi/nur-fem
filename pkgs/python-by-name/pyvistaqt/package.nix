{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools-scm,
  qtpy,
  pyqt6,
  pyvista,
  vtk,
  numpy,
  pytest-qt,
  pytest-cov,
  pytestCheckHook,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  version = "0.11.2";
  pname = "pyvistaqt";

  src = fetchFromGitHub {
    owner = "pyvista";
    repo = "pyvistaqt";
    tag = version;
    hash = "sha256-B8NyJVEYzqUAG2zi/YuowpRhbHUNprPA0F6Uh2hYsF0=";
  };

  postPatch = ''
    substituteInPlace tests/conftest.py \
      --replace-fail "pytest.skip(NO_PLOTTING, " "pytest.skip("
  '';

  build-system = [
    setuptools-scm
  ];

  dependencies = [
    qtpy
    pyqt6
    pyvista
  ];

  pythonImportsCheck = [ "pyvistaqt" ];

  # Qt related tests cannot run in sandbox
  doCheck = false;

  nativeCheckInputs = [
    vtk
    numpy
    pytest-qt
    pytest-cov
    pytestCheckHook
    writableTmpDirAsHomeHook
  ];

  meta = {
    homepage = "http://qtdocs.pyvista.org/";
    description = "Helper module for pyvista";
    changelog = "https://github.com/pyvista/pyvistaqt/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ qbisi ];
  };
}
