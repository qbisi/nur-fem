{
  lib,
  buildPythonPackage,
  fetchFromGitea,
  flit-core,
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

  build-system = [
    flit-core
  ];

  pythonImportsCheck = [ "pylit" ];

  meta = {
    homepage = "https://codeberg.org/milde/pylit";
    description = "Bidirectional text/code converter";
    changelog = "https://codeberg.org/milde/pylit/releases/tag/${src.tag}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ qbisi ];
  };
}
