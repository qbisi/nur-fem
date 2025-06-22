{
  lib,
  stdenv,
  version,
  fetchFromGitHub,
  cmake,
  configuration,
  opencascade-occt,
  testers,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "salome-commongeomlib";
  version = "9.14.0";

  src = fetchFromGitHub {
    owner = "SalomePlatform";
    repo = "common_geometry_lib";
    tag = "V${lib.concatStringsSep "_" (lib.versions.splitVersion finalAttrs.version)}";
    hash = "sha256-0D5k+aZfprD/3d7kgA30gnhCDMS5hywRykNNXXebCYo=";
  };

  nativeBuildInputs = [
    cmake
    configuration
  ];

  buildInputs = [
    opencascade-occt
  ];

  cmakeFlags = [
    (lib.cmakeFeature "CommonGeomLib_INSTALL_LIBS" "lib")
    (lib.cmakeFeature "CommonGeomLib_INSTALL_HEADERS" "include")
    (lib.cmakeFeature "CommonGeomLib_INSTALL_CMAKE_LOCAL" "lib/cmake/commongeomlib")
  ];

  passthru.tests = {
    cmake-config = testers.hasCmakeConfigModules {
      moduleNames = [ "CommonGeomLib" ];
      package = finalAttrs.finalPackage;
    };
  };

  setupHook = ./setup-hook.sh;

  meta = {
    description = "CommonGeomLib module of the SALOME platform";
    homepage = "https://www.salome-platform.org";
    downloadPage = "https://github.com/SalomePlatform/geom";
    license = with lib.licenses; [ lgpl21Plus ];
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ qbisi ];
  };
})
