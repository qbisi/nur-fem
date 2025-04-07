{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  mpi,
  metis,
  python3,
  python3Packages,
  pythonSupport ? true,
  isILP64 ? false,
}:
stdenv.mkDerivation (finalAttrs: {
  version = "3.18";
  pname = "kahip";

  src = fetchFromGitHub {
    owner = "KaHIP";
    repo = "KaHIP";
    tag = "v${finalAttrs.version}";
    hash = "sha256-l8DhVb2G6pQQcH3Wq4NsKw30cSK3sG+gCYRdpibw4ZI=";
  };

  nativeBuildInputs =
    [ cmake ]
    ++ lib.optionals pythonSupport [
      python3
      python3Packages.pybind11
    ];

  buildInputs = [
    mpi
    metis
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILDPYTHONMODULE" pythonSupport)
    (lib.cmakeBool "64BITMODE" isILP64)
  ];

  doCheck = true;

  meta = {
    homepage = "https://kahip.github.io/";
    description = "Karlsruhe HIGH Quality Partitioning";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ qbisi ];
  };
})
