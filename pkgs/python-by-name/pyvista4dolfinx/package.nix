{
  lib,
  buildPythonPackage,
  fetchFromGitLab,
  setuptools,
  fenics-dolfinx,
  pyvista,
  pyvistaqt,
  pytestCheckHook,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "pyvista4dolfinx";
  version = "0.9.1";
  pyproject = true;

  src = fetchFromGitLab {
    owner = "fenicsx4flow";
    repo = "pyvista4dolfinx";
    tag = version;
    hash = "sha256-msr9CNiGfIlrr1xeDhHBFTapa3ZlmtirKCW/ECNEaz0=";
  };

  build-system = [ setuptools ];

  dependencies = [
    pyvista
    pyvistaqt
    fenics-dolfinx
  ];

  pythonImportsCheck = [ "pyvista4dolfinx" ];

  nativeCheckInputs = [
    pytestCheckHook
    writableTmpDirAsHomeHook
  ];

  meta = {
    description = "Re-introduction of a simple plot function for Dolfinx";
    homepage = "https://gitlab.com/fenicsx4flow/pyvista4dolfinx";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ qbisi ];
  };
}
