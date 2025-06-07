{
  lib,
  python,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  trame-client,
}:

buildPythonPackage rec {
  pname = "trame-vtk";
  version = "2.8.15";
  format = "wheel";

  src = fetchPypi {
    pname = "trame_vtk";
    inherit version format;

    python = "py3";
    dist = "py3";
    hash = "sha256-q/fSPSZ90VuH20skkwKgrqhXLCYNIF4mTbpYNrOtySs=";
  };

  build-system = [ setuptools ];

  dependencies = [
    trame-client
  ];

  pythonImportsCheck = [ "trame_vtk" ];

  postFixup = ''
    rm -rf $out/${python.sitePackages}/{tests,examples}
    find $out/${python.sitePackages}/trame -type f -name '__init__.*' -delete
  '';

  meta = {
    description = "VTK widgets for trame";
    homepage = "https://github.com/Kitware/trame-vtk";
    changelog = "https://github.com/Kitware/trame-vtk/releases/tag/v${version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ qbisi ];
  };
}
