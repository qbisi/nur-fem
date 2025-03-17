{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  poetry-core,
  scipy,
  petsc4py,
  netgen-mesher,
  pytestCheckHook,
  ngsolve,
  pytest-mpi,
}:

buildPythonPackage rec {
  pname = "ngspetsc";
  version = "0.0.8";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "ngsolve";
    repo = "ngspetsc";
    tag = "v${version}";
    hash = "sha256-Ub7d0gQ0kPH09Vpy4bNZT+Bb3/5TKadSz27WfNFaAH8=";
  };

  # netgen-mesher has been built with opencascade-occt support
  # thus we do not need netgen-occt
  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'netgen-occt' '#netgen-occt' \
      --replace-fail 'project.optional-dependencies' 'tool.poetry.extras'
  '';

  build-system = [
    poetry-core
  ];

  dependencies = [
    scipy
    petsc4py
    netgen-mesher
  ];

  pythonImportsCheck = [ "ngsPETSc" ];

  nativeCheckInputs = [
    pytestCheckHook
    ngsolve
    pytest-mpi
    # slepc
  ];

  disabledTests = [
    # require slepc
    "test_eps.py"
  ];

  meta = {
    description = "Interface between PETSc and NGSolve/NETGEN";
    homepage = "https://ngspetsc.readthedocs.io/en/latest/";
    changelog = "https://github.com/NGSolve/ngsPETSc/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ qbisi ];
  };
}
