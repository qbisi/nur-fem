{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  procps,
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
  version = "0.45.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "pyvista";
    repo = "pyvista";
    tag = "v${version}";
    hash = "sha256-szI9kzJQOVCKcGTWj9Twq9i2DzbrHt/LmYBBfq6MBy8=";
  };

  postPatch = ''
    substituteInPlace pyvista/core/utilities/reader.py \
      --replace-fail 'vtkIOXdmf2' 'vtkIOXdmf3' \
      --replace-fail 'vtkXdmfReader' 'vtkXdmf3Reader' \
  '';

  pythonRelaxDeps = [ "vtk" ];

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
