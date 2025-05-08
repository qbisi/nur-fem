{
  lib,
  buildPythonPackage,
  fetchFromGitea,
  flit-core,
  pytestCheckHook,
}:

buildPythonPackage rec {
  version = "0.8.0";
  pname = "pylit";
  pyproject = true;

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "milde";
    repo = "pylit";
    tag = version;
    hash = "sha256-kXiWRRccv3ZI0v6efJRLYJ2Swx60W3QUtM1AEF6IMpo=";
  };

  # replace legacy nose module with pytest
  postPatch = ''
    substituteInPlace test/{pylit,pylit_ui}_test.py \
      --replace-fail "import nose" "import pytest" \
      --replace-fail "nose.runmodule()" "pytest.main()"
  '';

  build-system = [
    flit-core
  ];

  pythonImportsCheck = [ "pylit" ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  pytestFlagsArray = [ "test" ];

  meta = {
    homepage = "https://codeberg.org/milde/pylit";
    description = "Bidirectional text/code converter";
    mainProgram = "pylit";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ qbisi ];
  };
}
