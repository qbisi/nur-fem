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
  nixGLMesaHook,
  pytestCheckHook,
  headlessDisplayCheckHook,
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

  # This test failure maybe related to upstream Xwayland
  # (EE) Backtrace:
  # (EE) 0: /nix/store/mw5kn5fn7m335r404fr14w3jf9523ph4-xwayland-24.1.6/bin/Xwayland (OsSigHandler+0x33) [0x587063]
  # (EE) unw_get_proc_name failed: no unwind info found [-10]
  # (EE) 1: <signal handler called>
  # (EE) 2: /nix/store/mw5kn5fn7m335r404fr14w3jf9523ph4-xwayland-24.1.6/bin/Xwayland (xwl_cursor_warped_to+0x90) [0x429a20]
  # (EE) 3: /nix/store/mw5kn5fn7m335r404fr14w3jf9523ph4-xwayland-24.1.6/bin/Xwayland (ProcWarpPointer+0x1cc) [0x4b2dec]
  disabledTests = [
    "test_mouse_interactions"
  ];

  nativeCheckInputs = [
    pyqt6
    pytest-qt
    pytest-cov
    nixGLMesaHook
    pytestCheckHook
    headlessDisplayCheckHook
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
