{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  trame-common,
  pytestCheckHook,
  # seleniumbase,
  pytest-xprocess,
  pillow,
# pixelmatch,
}:

buildPythonPackage rec {
  pname = "trame-client";
  version = "3.9.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "kitware";
    repo = "trame-client";
    tag = "v${version}";
    hash = "sha256-8APnUbuogO2IYHnFAhbfVE3HVc3yz4FvjAsHxWKeHsc=";
  };

  build-system = [ setuptools ];

  dependencies = [ trame-common ];

  pythonImportsCheck = [ "trame_client" ];

  doCheck = false;

  nativeCheckInputs = [
    pytestCheckHook
    # seleniumbase
    pytest-xprocess
    pillow
    # pixelmatch
  ];

  meta = {
    description = "Internal client of trame";
    homepage = "https://github.com/Kitware/trame-client";
    changelog = "https://github.com/Kitware/trame-client/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ qbisi ];
  };
}
