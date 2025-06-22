{
  lib,
  stdenv,
  version,
  fetchFromGitHub,
  cmake,
  configuration,
  kernel,
  python3Packages,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "salome-gui";
  inherit version;

  src = fetchFromGitHub {
    owner = "SalomePlatform";
    repo = "gui";
    tag = "V${lib.concatStringsSep "_" (lib.versions.splitVersion finalAttrs.version)}";
    hash = "";
  };

  nativeBuildInputs = [
    cmake
    configuration
    # python3Packages.python
  ];

  buildInputs = [
    kernel
    # vtk
    # tbb
  ];

  cmakeFlags = [
    (lib.cmakeBool "SALOME_BUILD_TESTS" finalAttrs.finalPackage.doCheck)
    (lib.cmakeBool "SALOME_BUILD_DOC" false)
  ];

  doCheck = false;

  meta = {
    description = "GUI module of the SALOME platform";
    homepage = "https://www.salome-platform.org";
    downloadPage = "https://github.com/SalomePlatform/gui";
    license = with lib.licenses; [ lgpl21Plus ];
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ qbisi ];
  };
})
