{
  lib,
  python,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  hatch-jupyter-builder,
  jupyterlab,
  aiohttp,
  jupyter-server,
  simpervisor,
  tornado,
  traitlets,
}:

buildPythonPackage rec {
  pname = "jupyter-server-proxy";
  version = "4.4.0";
  format = "wheel";

  src = fetchPypi {
    pname = "jupyter_server_proxy";
    inherit version format;

    python = "py3";
    dist = "py3";
    hash = "sha256-cHtchIELuIY9UPbG1Qo4b+whYUnhGAK31MRRtUpjqaY=";
  };

  build-system = [
    hatchling
    hatch-jupyter-builder
    jupyterlab
  ];

  dependencies = [
    aiohttp
    jupyter-server
    simpervisor
    tornado
    traitlets
  ];

  pythonImportsCheck = [ "jupyter_server_proxy" ];

  doCheck = false;

  meta = {
    description = "Jupyter server extension to run additional processes and proxy to them that comes bundled JupyterLab extension to launch pre-defined processes";
    homepage = "https://github.com/jupyterhub/jupyter-server-proxy";
    changelog = "https://github.com/jupyterhub/jupyter-server-proxy/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ qbisi ];
  };
}
