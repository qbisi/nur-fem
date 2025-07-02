{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  trame-common,
  trame-client,
  trame-server,
  wslink,
  pyyaml,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "trame";
  version = "3.9.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "kitware";
    repo = "trame";
    tag = "v${version}";
    hash = "sha256-Mhr4mlXv5L5npWak0M3P2BVgkwsFTakvaOPG9D19qec=";
  };

  patches = [
    ./copytree-writable.patch
  ];

  postPatch = ''
    sed -i '/^\[tool\.setuptools\.packages\.find\]/a include = ["trame*"]' pyproject.toml
  '';

  build-system = [ setuptools ];

  dependencies = [
    trame-common
    trame-client
    trame-server
    wslink
    pyyaml
  ];

   __darwinAllowLocalNetworking = true;

  pythonImportsCheck = [ "trame" ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  meta = {
    description = "Framework to build applications in plain Python";
    homepage = "https://github.com/Kitware/trame";
    changelog = "https://github.com/Kitware/trame/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ qbisi ];
  };
}
