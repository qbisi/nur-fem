{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  configuration,
  kernel,
  geom,
  opencascade-occt,
  vtk,
  guiSupport,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "salome-netgenplugin";
  version = "9.14.0";

  src = fetchFromGitHub {
    owner = "SalomePlatform";
    repo = "netgenplugin";
    tag = "V${lib.concatStringsSep "_" (lib.versions.splitVersion finalAttrs.version)}";
    hash = "sha256-ooIR49c6tav4dfD1XqW2vZfF82X597dtVM899rfcGkA=";
  };

  nativeBuildInputs = [
    cmake
    configuration
  ];

  buildInputs = [
    kernel
    geom
    opencascade-occt
    vtk
  ];

  cmakeFlags = [
    (lib.cmakeBool "SALOME_BUILD_TESTS" finalAttrs.finalPackage.doCheck)
    (lib.cmakeBool "SALOME_BUILD_DOC" false)
    (lib.cmakeBool "SALOME_BUILD_GUI" guiSupport)
  ];

  doCheck = false;

  meta = {
    description = "Netgen Plugin for the SALOME Smesh Module";
    homepage = "https://www.salome-platform.org";
    downloadPage = "https://github.com/SalomePlatform/netgenplugin";
    license = with lib.licenses; [ lgpl21Plus ];
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ qbisi ];
  };
})
