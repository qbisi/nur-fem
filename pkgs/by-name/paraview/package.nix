{
  lib,
  stdenv,
  fetchurl,
  cmake,
  ninja,
  vtk,
  mpi,
  python3Packages,
  withQt5 ? false,
  withQt6 ? true,
  mpiSupport ? true,
  pythonSupport ? true,
}:
let
  inherit
    (vtk.override {
      inherit
        mpi
        mpiSupport
        python3Packages
        pythonSupport
        withQt5
        withQt6
        ;
    })
    vtkPackages
    ;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "paraview";
  version = "5.13.3";

  src = fetchurl {
    url = "https://www.paraview.org/files/v${lib.versions.majorMinor finalAttrs.version}/ParaView-v${finalAttrs.version}.tar.xz";
    hash = "sha256-O9MbtW4Hqiryo3mJV0W7xDDFZVGKNj2TXy78NbB23wk=";
  };

  cmakeFlags = [
    (lib.cmakeBool "PARAVIEW_VERSIONED_INSTALL" false)
    (lib.cmakeBool "PARAVIEW_USE_EXTERNAL_VTK" true)
    (lib.cmakeBool "PARAVIEW_BUILD_WITH_EXTERNAL" true)
    (lib.cmakeBool "PARAVIEW_ENABLE_VISITBRIDGE" true)
    (lib.cmakeBool "PARAVIEW_USE_PYTHON" pythonSupport)
    (lib.cmakeBool "PARAVIEW_ENABLE_WEB" pythonSupport)
    (lib.cmakeBool "PARAVIEW_USE_MPI" mpiSupport)
    (lib.cmakeFeature "CMAKE_INSTALL_BINDIR" "bin")
    (lib.cmakeFeature "CMAKE_INSTALL_LIBDIR" "lib")
    (lib.cmakeFeature "CMAKE_INSTALL_INCLUDEDIR" "include")
  ];

  nativeBuildInputs = [
    cmake
    ninja
    vtkPackages.qtPackages.wrapQtAppsHook
  ];

  buildInputs = [
    vtkPackages.vtk
  ];

  dontWrapQtApps = true;

  meta = {
    homepage = "https://www.paraview.org";
    description = "3D Data analysis and visualization application";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [
      guibert
      qbisi
    ];
    changelog = "https://www.kitware.com/paraview-${lib.concatStringsSep "-" (lib.versions.splitVersion finalAttrs.version)}-release-notes";
    platforms = lib.platforms.linux;
  };
})
