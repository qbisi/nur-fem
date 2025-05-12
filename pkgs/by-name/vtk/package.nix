{
  lib,
  stdenv,
  fetchurl,
  cmake,
  libpng,
  libtiff,
  libGL,
  libX11,
  qt6,
  python3Packages,

  # custom options
  enablePython ? true,
  enableEgl ? !stdenv.hostPlatform.isDarwin,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "vtk";
  version = "9.4.2";

  src = fetchurl {
    url = "https://www.vtk.org/files/release/${lib.versions.majorMinor finalAttrs.version}/VTK-${finalAttrs.version}.tar.gz";
    hash = "sha256-NsmODalrsSow/lNwgJeqlJLntm1cOzZuHI3CUeKFagI=";
  };

  nativeBuildInputs =
    [
      cmake
    ]
    ++ lib.optionals enablePython [
      python3Packages.python
    ];

  buildInputs = [
    libpng
    libtiff
    qt6.qttools
    qt6.qtdeclarative
  ];

  propagatedBuildInputs =
    [
      libX11
      libGL
    ]
    ++ lib.optionals enablePython [
      (python3Packages.mkPythonMetaPackage {
        inherit (finalAttrs) pname version meta;
        dependencies = with python3Packages; [
          numpy
          matplotlib
        ];
      })
    ];

  cmakeFlags =
    [
      (lib.cmakeBool "VTK_VERSIONED_INSTALL" false)
      (lib.cmakeBool "VTK_OPENGL_HAS_EGL" enableEgl)
      (lib.cmakeBool "VTK_MODULE_USE_EXTERNAL_vtkpng" true)
      (lib.cmakeBool "VTK_MODULE_USE_EXTERNAL_vtktiff" true)
      (lib.cmakeFeature "CMAKE_INSTALL_LIBDIR" "lib")
      (lib.cmakeFeature "CMAKE_INSTALL_INCLUDEDIR" "include")
      (lib.cmakeFeature "CMAKE_INSTALL_BINDIR" "bin")
      (lib.cmakeFeature "VTK_GROUP_ENABLE_Qt" "YES")
      (lib.cmakeFeature "VTK_QT_VERSION" "6")
    ]
    ++ lib.optionals enablePython [
      (lib.cmakeBool "VTK_WRAP_PYTHON" true)
      (lib.cmakeFeature "VTK_PYTHON_VERSION" "3")
    ];

  dontWrapQtApps = true;

  postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    patchelf --add-rpath ${lib.getLib libGL}/lib $out/lib/libvtkglad.so
  '';

  meta = {
    description = "Open source libraries for 3D computer graphics, image processing and visualization";
    homepage = "https://www.vtk.org/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [
      qbisi
    ];
    platforms = lib.platforms.unix;
    badPlatforms = lib.optionals enableEgl lib.platforms.darwin;
  };
})
