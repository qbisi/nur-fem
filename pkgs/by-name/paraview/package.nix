{
  lib,
  stdenv,
  fetchurl,
  cmake,
  ninja,
  vtk,
  catalyst,
  protobuf,
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
  version = "6.0.0-RC1";

  src = fetchurl {
    url = "https://www.paraview.org/files/v${lib.versions.majorMinor finalAttrs.version}/ParaView-v${finalAttrs.version}.tar.xz";
    hash = "sha256-5EI02JrrfTqLH8J1xZO7D/Q+hY4pVcFOhvJE4ilR0vk=";
  };

  cmakeFlags = [
    (lib.cmakeBool "PARAVIEW_VERSIONED_INSTALL" false)
    (lib.cmakeBool "PARAVIEW_USE_EXTERNAL_VTK" true)
    # (lib.cmakeBool "PARAVIEW_ENABLE_EXAMPLES" true)
    (lib.cmakeBool "PARAVIEW_ENABLE_CATALYST" true)
    (lib.cmakeBool "PARAVIEW_ENABLE_VISITBRIDGE" true)
    (lib.cmakeBool "PARAVIEW_ENABLE_ADIOS2" true)
    (lib.cmakeBool "PARAVIEW_ENABLE_FFMPEG" true)
    (lib.cmakeBool "PARAVIEW_ENABLE_FIDES" true)
    # (lib.cmakeBool "PARAVIEW_ENABLE_GDAL" true)
    (lib.cmakeBool "PARAVIEW_ENABLE_OPENTURNS" true)
    # (lib.cmakeBool "PARAVIEW_ENABLE_PDAL" true)
    (lib.cmakeBool "PARAVIEW_ENABLE_XDMF3" true)
    # (lib.cmakeBool "PARAVIEW_PLUGINS_DEFAULT" true)
    # (lib.cmakeBool "PARAVIEW_PLUGIN_dsp_enable_audio_player" true)
    # (lib.cmakeBool "PARAVIEW_PLUGIN_ENABLE_NetCDFTimeAnnotationPlugin" true)
    # (lib.cmakeBool "PARAVIEW_PLUGIN_ENABLE_pvNVIDIAIndeX" true)
    # (lib.cmakeBool "PARAVIEW_PLUGIN_ENABLE_CDIReader" true) # https://gitlab.dkrz.de/mpim-sw/libcdi
    # (lib.cmakeBool "PARAVIEW_PLUGIN_ENABLE_PythonQtPlugin" true)
    (lib.cmakeBool "PARAVIEW_USE_PYTHON" pythonSupport)
    (lib.cmakeBool "PARAVIEW_USE_MPI" mpiSupport)
    (lib.cmakeBool "PARAVIEW_USE_QT" (withQt5 || withQt6))
    (lib.cmakeFeature "CMAKE_INSTALL_BINDIR" "bin")
    (lib.cmakeFeature "CMAKE_INSTALL_LIBDIR" "lib")
    (lib.cmakeFeature "CMAKE_INSTALL_INCLUDEDIR" "include")
    (lib.cmakeFeature "CMAKE_INSTALL_DOCDIR" "share/doc/ParaView")
  ];

  nativeBuildInputs = [
    cmake
    ninja
    vtkPackages.qtPackages.wrapQtAppsHook
  ];

  buildInputs = [
    vtkPackages.vtk
    vtkPackages.qtPackages.qt5compat
    catalyst
    protobuf
    # python3Packages.cftime
  ];

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
