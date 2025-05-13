{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  matplotlib,
  numpy,
  pillow,
  pooch,
  pythonAtLeast,
  scooby,
  setuptools,
  typing-extensions,
  vtk,

  # tests
  pytestCheckHook,
  writableTmpDirAsHomeHook,
  trimesh,
  ipython,
  scipy,
  hypothesis,
  pytest-cases,
  meshio,
}:

buildPythonPackage rec {
  pname = "pyvista";
  version = "0.45.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "pyvista";
    repo = "pyvista";
    tag = "v${version}";
    hash = "sha256-L2CjS/12TfVG9elr97pgXfjNc3EJojTy0S6Z3sDu280=";
  };

  build-system = [ setuptools ];

  dependencies = [
    matplotlib
    numpy
    pillow
    pooch
    scooby
    typing-extensions
    vtk
  ];

  pythonImportsCheck = [ "pyvista" ];

  doCheck = false;

  nativeCheckInputs = [
    pytestCheckHook
    writableTmpDirAsHomeHook
    trimesh
    ipython
    scipy
    hypothesis
    pytest-cases
    meshio
  ];

  meta = {
    description = "Easier Pythonic interface to VTK";
    homepage = "https://pyvista.org";
    changelog = "https://github.com/pyvista/pyvista/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ wegank ];
  };
}
