{
  lib,
  buildPythonPackage,
  fetchFromGitLab,
  setuptools,
  fenics-dolfinx,
  pyvista,
  pyvistaqt,
  pytestCheckHook,
  headlessDisplayHook2,
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
    headlessDisplayHook2
    writableTmpDirAsHomeHook
  ];

  env.ALLOW_PLOTTING = "true";

  meta = {
    description = "Re-introduction of a simple plot function for Dolfinx";
    homepage = "https://gitlab.com/fenicsx4flow/pyvista4dolfinx";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ qbisi ];
  };
}
