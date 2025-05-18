{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  hatchling,
}:

buildPythonPackage rec {
  pname = "simpervisor";
  version = "1.0.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "jupyterhub";
    repo = "simpervisor";
    tag = "v${version}";
    hash = "sha256-73vkiQtOT0M9Vww1nYZ76JR2koWt/NPIav46k1fHOzc=";
  };

  build-system = [ hatchling ];

  pythonImportsCheck = [ "simpervisor" ];

  doCheck = false;

  meta = {
    description = "Simple async process supervisor";
    homepage = "https://github.com/jupyterhub/simpervisor";
    changelog = "https://github.com/jupyterhub/simpervisor/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ qbisi ];
  };
}
