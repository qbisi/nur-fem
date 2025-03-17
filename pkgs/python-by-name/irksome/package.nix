{ lib
, fetchFromGitHub
, buildPythonPackage
}:

# depend on firedrake

buildPythonPackage rec {
  version = "0-unstable-2024-08-03";
  pname = "irksome";

  src = fetchFromGitHub {
    owner = "firedrakeproject";
    repo = "irksome";
    tag = "ed30518f2ca30dfb54030fbba5191384fa72c047";
    sha256 = "sha256-JXl6wrTdztVBSDt6waSwUgz5Ocdjb9MFEj+YGs0Vntc=";
  };

  # check requires import firedrake module
  # pythonImportsCheck = [
  #   "irksome"
  # ];

  # nativeCheckInputs = with pythonPackages; [ pytestCheckHook mpi4py fiat ufl];

  meta = {
    homepage = "https://www.firedrakeproject.org/Irksome";
    description = "Generate Runge-Kutta methods from a semi-discrete UFL form";
    license = lib.licenses.lgpl3;
    maintainers = with lib.maintainers; [ qbisi ];
  };
}
