{
  lib,
  python,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  trame-client,
}:

buildPythonPackage rec {
  pname = "trame-vuetify";
  version = "3.0.1";
  format = "wheel";

  src = fetchPypi {
    pname = "trame_vuetify";
    inherit version format;

    python = "py3";
    dist = "py3";
    hash = "sha256-dhXN6ZyVCjaokFtJFap8oUvIn9o0AhLYmFq923xMpnc=";
  };

  build-system = [ setuptools ];

  dependencies = [
    trame-client
  ];

  pythonImportsCheck = [ "trame_vuetify" ];

  postFixup = ''
    find $out/${python.sitePackages}/trame -type f -name '__init__.*' -delete
  '';

  meta = {
    description = "Vuetify widgets for trame";
    homepage = "https://github.com/Kitware/trame-vuetify";
    changelog = "https://github.com/Kitware/trame-vuetify/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ qbisi ];
  };
}
