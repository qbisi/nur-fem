{
  lib,
  callPackage,
  fetchFromGitHub,
  buildPythonPackage,
  networkx,
  numpy,
  six,
  pulp,
  pytestCheckHook,
}:

# Mark Obsolete

buildPythonPackage rec {
  version = "20230510.0";
  pname = "coffee";

  src = fetchFromGitHub {
    owner = "coneoproject";
    repo = "COFFEE";
    tag = "Firedrake_${version}";
    sha256 = "sha256-av3JLE6o4v3VhJKMm5FiWjtdb3mRBZ1Xhjz2CkUCa5A=";
  };

  dependencies = [
    networkx
    numpy
    six
    pulp
  ];

  pythonImportsCheck = [
    "coffee"
    "coffee.visitors"
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  meta = {
    homepage = "https://github.com/coneoproject/COFFEE";
    description = "COmpiler For Fast Expression Evaluation (COFFEE)";
    changelog = "https://github.com/coneoproject/COFFEE/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ qbisi ];
  };
}
