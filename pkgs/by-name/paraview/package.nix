{
  lib,
  stdenv,
  fetchurl,
  fetchzip,
  cmake,
  ninja,
  catalyst,
  protobuf,
  python3Packages,
  qt6Packages,
}:
stdenv.mkDerivation (
  finalAttrs:
  let
    paraviewFilesUrl = "https://www.paraview.org/files/v${lib.versions.majorMinor finalAttrs.version}";
    doc = fetchurl {
      url = "${paraviewFilesUrl}/ParaViewGettingStarted-6.0.0.pdf";
      name = "GettingStarted.pdf";
      hash = "sha256-egoRRrxUiKL0sSqxEqpOTZRWsfFyMkil/m3V/XBFBN4=";
    };
    examples = fetchzip {
      url = "${paraviewFilesUrl}/ParaView-${finalAttrs.version}-MPI-Linux-Python3.12-x86_64.tar.gz";
      hash = "sha256-y9ecUYkR44s5zC+scIxP3VS+O0sUm7ZBjCZ7Mxr4Y94=";
      postFetch = ''
        mv $out/share/paraview-${lib.versions.majorMinor finalAttrs.version}/examples .
        rm $out -rf
        mkdir -p $out
        mv examples $out
      '';
    };
  in
  {
    pname = "paraview";
    version = "6.0.0-RC1";

    src = fetchurl {
      url = "${paraviewFilesUrl}/ParaView-v${finalAttrs.version}.tar.xz";
      hash = "sha256-5EI02JrrfTqLH8J1xZO7D/Q+hY4pVcFOhvJE4ilR0vk=";
    };

    postPatch = ''
      substituteInPlace Remoting/Core/vtkPVFileInformation.cxx \
        --replace-fail "return resource_dir;" "return \"$out/share/paraview\";"
    '';

    cmakeFlags = [
      (lib.cmakeBool "PARAVIEW_VERSIONED_INSTALL" false)
      (lib.cmakeBool "PARAVIEW_BUILD_WITH_EXTERNAL" true)
      (lib.cmakeBool "PARAVIEW_USE_EXTERNAL_VTK" true)
      (lib.cmakeBool "PARAVIEW_USE_QT" true)
      (lib.cmakeBool "PARAVIEW_USE_MPI" true)
      (lib.cmakeBool "PARAVIEW_USE_PYTHON" true)
      (lib.cmakeBool "PARAVIEW_ENABLE_WEB" true)
      (lib.cmakeBool "PARAVIEW_ENABLE_EXAMPLES" true)
      (lib.cmakeBool "PARAVIEW_ENABLE_CATALYST" true)
      (lib.cmakeBool "PARAVIEW_ENABLE_VISITBRIDGE" true)
      (lib.cmakeBool "PARAVIEW_ENABLE_ADIOS2" true)
      (lib.cmakeBool "PARAVIEW_ENABLE_FFMPEG" true)
      (lib.cmakeBool "PARAVIEW_ENABLE_FIDES" true)
      (lib.cmakeBool "PARAVIEW_ENABLE_ALEMBIC" true)
      (lib.cmakeBool "PARAVIEW_ENABLE_LAS" true)
      (lib.cmakeBool "PARAVIEW_ENABLE_GDAL" true)
      (lib.cmakeBool "PARAVIEW_ENABLE_PDAL" true)
      (lib.cmakeBool "PARAVIEW_ENABLE_OPENTURNS" true)
      (lib.cmakeBool "PARAVIEW_ENABLE_MOTIONFX" true)
      (lib.cmakeBool "PARAVIEW_ENABLE_OCCT" true)
      (lib.cmakeBool "PARAVIEW_ENABLE_XDMF3" true)
      (lib.cmakeFeature "CMAKE_INSTALL_BINDIR" "bin")
      (lib.cmakeFeature "CMAKE_INSTALL_LIBDIR" "lib")
      (lib.cmakeFeature "CMAKE_INSTALL_INCLUDEDIR" "include")
      (lib.cmakeFeature "CMAKE_INSTALL_DOCDIR" "share/paraview/doc")
    ];

    nativeBuildInputs = [
      cmake
      ninja
      qt6Packages.wrapQtAppsHook
    ];

    buildInputs = [
      qt6Packages.qttools
      qt6Packages.qt5compat
      catalyst
      protobuf
    ];

    propagatedBuildInputs = [
      (python3Packages.mkPythonMetaPackage {
        inherit (finalAttrs) pname version meta;
        dependencies = [
          python3Packages.vtk
        ];
      })
    ];

    postInstall =
      ''
        install -Dm644 ${doc} $out/share/paraview/doc/${doc.name}
        cp -r ${examples}/examples $out/share/paraview
        python -m compileall -s $out $out/${python3Packages.python.sitePackages}
      ''
      + lib.optionalString stdenv.hostPlatform.isLinux ''
        install -Dm644 ../Qt/Components/Resources/Icons/pvIcon.svg $out/share/icons/hicolor/scalable/apps/paraview.svg
      ''
      + lib.optionalString stdenv.hostPlatform.isDarwin ''
        ln -s ../Applications/paraview.app/Contents/MacOS/paraview $out/bin/paraview
      '';

    meta = {
      description = "3D Data analysis and visualization application";
      homepage = "https://www.paraview.org";
      changelog = "https://www.kitware.com/paraview-${lib.concatStringsSep "-" (lib.versions.splitVersion finalAttrs.version)}-release-notes";
      mainProgram = "paraview";
      license = lib.licenses.bsd3;
      platforms = lib.platforms.unix;
      maintainers = with lib.maintainers; [
        guibert
        qbisi
      ];
    };
  }
)
