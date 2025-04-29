{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  spdlog,
  pugixml,
  boost,
  petsc,
  slepc,
  adios2,
  kahip,
  python3Packages,

  # Override buildInputs as python module.
  # Reduce closure size when used py python module fenics-dolfinx.
  pythonSupport ? false,
}:
let
  fenicsPackages = petsc.petscPackages.overrideScope (
    final: prev: {
      inherit pythonSupport;
      slepc = final.callPackage slepc.override { };
      adios2 = final.callPackage adios2.override { };
      kahip = final.callPackage kahip.override { };
    }
  );
in
stdenv.mkDerivation (finalAttrs: {
  version = "0.9.0.post1";
  pname = "dolfinx";

  src = fetchFromGitHub {
    owner = "fenics";
    repo = "dolfinx";
    tag = "v${finalAttrs.version}";
    hash = "sha256-4IIx7vUZeDwOGVdyC2PBvfhVjrmGZeVQKAwgDYScbY0=";
  };

  preConfigure = "cd cpp";

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    spdlog
    pugixml
    boost
    fenicsPackages.mpi
    fenicsPackages.scotch
    fenicsPackages.hdf5
    fenicsPackages.petsc
    fenicsPackages.slepc
    fenicsPackages.kahip
    fenicsPackages.adios2
    python3Packages.fenics-basix
    python3Packages.fenics-ffcx
  ] ++ lib.optional withParmetis fenicsPackages.parmetis;

  cmakeFlags = [
    (lib.cmakeBool "DOLFINX_ENABLE_ADIOS2" true)
    (lib.cmakeBool "DOLFINX_ENABLE_PETSC" true)
    (lib.cmakeBool "DOLFIN_ENABLE_PARMETIS" withParmetis)
    (lib.cmakeBool "DOLFINX_ENABLE_SCOTCH" true)
    (lib.cmakeBool "DOLFINX_ENABLE_SLEPC" true)
    (lib.cmakeBool "DOLFINX_ENABLE_KAHIP" true)
    (lib.cmakeFeature "CMAKE_INSTALL_BINDIR" "bin")
    (lib.cmakeFeature "CMAKE_INSTALL_LIBDIR" "lib")
    (lib.cmakeFeature "CMAKE_INSTALL_INCLUDEDIR" "include")
  ];

  meta = {
    homepage = "https://github.com/fenics/dolfinx";
    description = "Next generation FEniCS problem solving environment";
    changelog = "https://github.com/fenics/dolfinx/releases/tag/${finalAttrs.src.tag}";
    license = with lib.licenses; [
      gpl3Plus
      lgpl3Plus
    ];
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ qbisi ];
  };
})
