{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  python3,
  python3Packages,
  mpi,
  petsc,
  scotch,
  slepc,
  spdlog,
  pugixml,
  boost,
  hdf5-mpi,
}:

stdenv.mkDerivation (finalAttrs: {
  version = "0.9.0.post1";
  pname = "dolfinx";

  src = fetchFromGitHub {
    owner = "fenics";
    repo = "dolfinx";
    tag = "v${finalAttrs.version}";
    hash = "sha256-4IIx7vUZeDwOGVdyC2PBvfhVjrmGZeVQKAwgDYScbY0=";
  };

  sourceRoot = "source/cpp";

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    mpi
    petsc
    scotch
    slepc
    spdlog
    pugixml
    boost
    hdf5-mpi
    python3Packages.fenics-basix # link to basix lib only
    python3Packages.fenics-ffcx # link to ffcx lib only
  ];

  cmakeFlags = [
    (lib.cmakeBool "DOLFINX_ENABLE_ADIOS2" false)
    (lib.cmakeBool "DOLFINX_ENABLE_PETSC" true)
    (lib.cmakeBool "DOLFIN_ENABLE_PARMETIS" false)
    (lib.cmakeBool "DOLFINX_ENABLE_SCOTCH" true)
    (lib.cmakeBool "DOLFINX_ENABLE_SLEPC" true)
    (lib.cmakeBool "DOLFINX_ENABLE_KAHIP" false)
    (lib.cmakeFeature "CMAKE_INSTALL_BINDIR" "bin")
    (lib.cmakeFeature "CMAKE_INSTALL_LIBDIR" "lib")
    (lib.cmakeFeature "CMAKE_INSTALL_INCLUDEDIR" "include")
  ];

  doCheck = true;

  meta = {
    homepage = "https://github.com/fenics/dolfinx";
    description = "Next generation FEniCS problem solving environment";
    changelog = "https://github.com/fenics/dolfinx/releases/tag/${finalAttrs.src.tag}";
    license = with lib.licenses; [
      gpl3Plus
      lgpl3Plus
    ];
    maintainers = with lib.maintainers; [ qbisi ];
  };
})
