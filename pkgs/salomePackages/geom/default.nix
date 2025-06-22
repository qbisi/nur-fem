{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  configuration,
  kernel,
  commongeomlib,
  libxml2,
  hdf5,
  boost,
  eigen,
  opencascade-occt,
  vtk,
  qt6Packages,
  cppunit,
  python3,
  guiSupport,
  testers,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "salome-geom";
  version = "9.14.0";

  src = fetchFromGitHub {
    owner = "SalomePlatform";
    repo = "geom";
    tag = "V${lib.concatStringsSep "_" (lib.versions.splitVersion finalAttrs.version)}";
    hash = "sha256-9Epfu5iPTTbIDQLOjqQHHkwwzJt4h89UiVkr4o+2LMw=";
  };

  postPatch = ''
    substituteInPlace src/GEOMImpl/GEOMImpl_ShapeDriver.cxx \
      --replace-fail "FixCurves" "FixEdgeCurves" \
      --replace-fail "StatusCurves" "StatusEdgeCurves"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    configuration
    qt6Packages.qttools
  ];

  buildInputs = [
    kernel
    commongeomlib
    libxml2
    hdf5
    boost
    eigen
    opencascade-occt
    vtk
  ];

  cmakeFlags = [
    (lib.cmakeBool "SALOME_BUILD_TESTS" finalAttrs.finalPackage.doCheck)
    (lib.cmakeBool "SALOME_BUILD_DOC" false)
    (lib.cmakeBool "SALOME_BUILD_GUI" guiSupport)
    (lib.cmakeFeature "LIBXML2_LIBRARY" "xml2")
  ];

  doCheck = true;

  preCheck = ''
    export PYTHONPATH=${kernel}/bin:$PYTHONPATH
    export SalomeAppConfig=""
  '';

  nativeCheckInputs = [
    cppunit
    python3
  ];

  dontWrapQtApps = true;

  setupHook = ./setup-hook.sh;

  passthru.tests = {
    cmake-config = testers.hasCmakeConfigModules {
      moduleNames = [ "SalomeGEOM" ];
      package = finalAttrs.finalPackage;
    };
  };

  meta = {
    description = "Geom module of the SALOME platform";
    homepage = "https://www.salome-platform.org";
    downloadPage = "https://github.com/SalomePlatform/geom";
    license = with lib.licenses; [ lgpl21Plus ];
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ qbisi ];
  };
})
