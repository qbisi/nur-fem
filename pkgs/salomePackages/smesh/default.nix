{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  configuration,
  kernel,
  geom,
  medfile,
  medcoupling,
  vtk,
  tbb,
  python3Packages,
  guiSupport,
  isILP64 ? false,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "salome-smesh";
  version = "9.14.0";

  src = fetchFromGitHub {
    owner = "SalomePlatform";
    repo = "smesh";
    tag = "V${lib.concatStringsSep "_" (lib.versions.splitVersion finalAttrs.version)}";
    hash = "sha256-B4MowHlzh9DBWSez73P/cBPmjQ1dY0zOPf9DMNKls1E=";
  };

  patches = [ ./0001-medwrapper-update-med-version-expected.patch ];

  nativeBuildInputs = [
    cmake
    configuration
    python3Packages.python
  ];

  buildInputs = [
    medfile
    kernel
    geom
    medcoupling
    vtk
    tbb
  ];

  cmakeFlags = [
    (lib.cmakeBool "SALOME_BUILD_TESTS" finalAttrs.finalPackage.doCheck)
    (lib.cmakeBool "SALOME_BUILD_DOC" false)
    (lib.cmakeBool "SALOME_BUILD_GUI" guiSupport)
    (lib.cmakeBool "SALOME_USE_64BIT_IDS" isILP64)
    (lib.cmakeBool "SALOME_SMESH_USE_TBB" true)
    (lib.cmakeBool "SALOME_SMESH_USE_CGNS" false)
  ];

  doCheck = false;

  setupHook = ./setup-hook.sh;

  meta = {
    description = "Kernel module of the SALOME platform";
    homepage = "https://www.salome-platform.org";
    downloadPage = "https://github.com/SalomePlatform/kernel";
    license = with lib.licenses; [ lgpl21Plus ];
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ qbisi ];
  };
})
