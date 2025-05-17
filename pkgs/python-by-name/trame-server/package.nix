{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  wslink,
  more-itertools,
  pytestCheckHook,
  pytest-asyncio
}:

buildPythonPackage rec {
  pname = "trame-server";
  version = "3.4.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "kitware";
    repo = "trame-server";
    tag = "v${version}";
    hash = "sha256-krrrQ4D1sQZyzck7O4IhC6cEFEsFNJD/iHV1ZyJG570=";
  };

  postPatch = ''
    sed -i '/^\[tool\.setuptools\.packages\.find\]/a include = ["trame_server*"]' pyproject.toml
  '';

  build-system = [ setuptools ];

  dependencies = [
    wslink
    more-itertools
  ];

  pythonImportsCheck = [ "trame_server" ];

  # require cyclic dependcies of tramp
  doCheck = false;

  meta = {
    description = "Internal server side implementation of trame";
    homepage = "https://github.com/Kitware/trame-server";
    changelog = "https://github.com/Kitware/trame-server/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ qbisi ];
  };
}
