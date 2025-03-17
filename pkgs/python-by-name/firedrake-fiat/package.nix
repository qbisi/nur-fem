{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  fetchFromBitbucket,
  setuptools,
  numpy,
  scipy,
  sympy,
  recursivenodes,
  symengine,
  firedrake-ufl,
  pytestCheckHook,
}:
let
  fiat-reference-data = fetchFromBitbucket {
    owner = "fenics-project";
    repo = "fiat-reference-data";
    rev = "0c8c97f7e4919402129e5ff3b54e3f0b9e902b7c";
    hash = "sha256-vdCkmCkKvLSYACF6MnZ/WuKuCNAoC3uu1A/9m9KwBK8=";
  };
in
buildPythonPackage rec {
  version = "20250218.0";
  pname = "firdrake-fiat";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "firedrakeproject";
    repo = "fiat";
    tag = "Firedrake_${version}";
    hash = "sha256-wvqKnNBAjkG7Qo2XeeMRVOCoHCdIGM6N51ULbyBZBoo=";
  };

  postPatch = ''
    ln -s ${fiat-reference-data} test/FIAT/regression/fiat-reference-data
  '';

  build-system = [ setuptools ];

  dependencies = [
    numpy
    scipy
    sympy
    recursivenodes
    firedrake-ufl
    symengine
  ];

  pythonImportsCheck = [ "FIAT" ];

  nativeCheckInputs = [ pytestCheckHook ];

  pytestFlagsArray = [
    "--skip-download"
  ];

  meta = {
    homepage = "https://github.com/firedrakeproject/fiat";
    description = "FInite element Automatic Tabulator (firedrake fork)";
    longDescription = ''
      The FInite element Automatic Tabulator FIAT supports generation of arbitrary
      order instances of the Lagrange elements on lines, triangles,and tetrahedra.
      It is also capable of generating arbitrary order instances of Jacobi-type
      quadrature rules on the same element shapes. Further, H(div) and H(curl)
      conforming finite element spaces such as the families of Raviart-Thomas,
      Brezzi-Douglas-Marini and Nedelec are supported on triangles and tetrahedra.
      Upcoming versions will also support Hermite and nonconforming elements.
    '';
    changelog = "https://github.com/firedrakeproject/fiat/releases/tag/${src.tag}";
    license = lib.licenses.lgpl3;
    maintainers = with lib.maintainers; [ qbisi ];
  };
}
