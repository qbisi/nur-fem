{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  trame-client,
}:

buildPythonPackage rec {
  pname = "trame-vtk";
  version = "2.8.15";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "kitware";
    repo = "trame-vtk";
    tag = "v${version}";
    hash = "sha256-2t8Lc/JQ8oQCkIPRN8uOKhEabNdDAnM/tr+3cC+Au14=";
  };

  postPatch = ''
    sed -i '/^\[tool\.setuptools\.packages\.find\]/a include = ["trame*"]' pyproject.toml
    find trame -type f -name '__init__.py' -delete
  '';

  build-system = [ setuptools ];

  dependencies = [
    trame-client
  ];

  pythonImportsCheck = [ "trame_vtk" ];

  meta = {
    description = "VTK widgets for trame";
    homepage = "https://github.com/Kitware/trame-vtk";
    changelog = "https://github.com/Kitware/trame-vtk/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ qbisi ];
  };
}
