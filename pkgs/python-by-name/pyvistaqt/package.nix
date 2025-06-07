{
  lib,
  stdenv,
  buildPythonPackage,
  fetchFromGitHub,

  # build-system
  setuptools,
  setuptools-scm,

  # dependencies
  qtpy,
  pyvista,

  # test
  pyqt6,
  pytest,
  pytest-qt,
  pytest-cov,
  pytestCheckHook,
  headlessDisplayHook2,
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
    setuptools
    setuptools-scm
  ];

  dependencies = [
    qtpy
    pyvista
  ];

  pythonImportsCheck = [ "pyvistaqt" ];

  doCheck = !stdenv.hostPlatform.isDarwin;

  disabledTests = [
    "test_mouse_interactions"
  ];

  nativeCheckInputs = [
    pyqt6
    pytest-qt
    pytest-cov
    pytestCheckHook
    headlessDisplayHook2
    writableTmpDirAsHomeHook
  ];

  # capable of doing onscreen/offscreen plot
  env.ALLOW_PLOTTING = "true";

  meta = {
    homepage = "http://qtdocs.pyvista.org/";
    downloadPage = "https://github.com/pyvista/pyvistaqt";
    description = "Helper module for pyvista";
    changelog = "https://github.com/pyvista/pyvistaqt/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ qbisi ];
  };
}
