{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  jupyterlab,
  jupyter_server,
  trame,
}:

buildPythonPackage rec {
  pname = "trame-jupyter-extension";
  version = "2.1.4";
  format = "wheel";

  src = fetchPypi {
    pname = "trame_jupyter_extension";
    inherit version format;

    python = "py3";
    dist = "py3";
    hash = "sha256-bdyQXNMOGVSnpF9g1kLQzgAKopAPw8o/mGdjbE9Zs+g=";
  };

  build-system = [
    hatchling
    jupyterlab
  ];

  dependencies = [
    jupyterlab
    jupyter_server
    trame
  ];

  pythonImportsCheck = [ "trame_jupyter_extension" ];

  meta = {
    description = "JupyterLab extension for trame communication layer";
    homepage = "https://github.com/Kitware/trame-jupyter-extension";
    changelog = "https://github.com/Kitware/trame-jupyter-extension/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ qbisi ];
  };
}
