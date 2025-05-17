{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  hatchling,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "trame-common";
  version = "0.2.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "kitware";
    repo = "trame-common";
    tag = "v${version}";
    hash = "sha256-SvnRk5qYzVQBnWQf6/pmYQeCWprs3xSNMaIa5DhMEFI=";
  };

  build-system = [ hatchling ];

  pythonImportsCheck = [ "trame_common" ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  meta = {
    description = "Dependency less classes and functions for trame";
    homepage = "https://github.com/Kitware/trame-common";
    changelog = "https://github.com/Kitware/trame-common/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ qbisi ];
  };
}
