{
  lib,
  newScope,
  stdenv,
  llvmPackages_18,
  fetchurl,
  fetchpatch2,
  cmake,
  pkg-config,

  # common dependencies
  tk,
  mpi,
  python3Packages,
  catalyst,
  cli11,
  boost,
  eigen,
  verdict,
  double-conversion,

  # common data libraries
  lz4,
  xz,
  zlib,
  pugixml,
  expat,
  jsoncpp,
  libxml2,
  exprtk,
  utf8cpp,
  libarchive,
  nlohmann_json,

  # filters
  openturns,
  openslide,

  # io modules
  adios2,
  libLAS,
  libgeotiff,
  laszip_2,
  gdal,
  pdal,
  alembic,
  imath,
  openvdb,
  c-blosc,
  unixODBC,
  postgresql,
  libmysqlclient,
  ffmpeg,
  libjpeg,
  libpng,
  libtiff,
  proj,
  sqlite,
  libogg,
  libharu,
  libtheora,
  hdf5,
  netcdf,
  opencascade-occt,

  # threading
  tbb,

  # rendering
  freetype,
  fontconfig,
  libX11,
  libXfixes,
  libXrender,
  libXcursor,
  gl2ps,
  libGL,
  libGLU,
  libglut,
  qt5,
  qt6,

  # check
  ctestCheckHook,
  headlessDisplayHook2,
  mpiCheckPhaseHook,

  # custom options
  withQt5 ? false,
  withQt6 ? false,
  # To avoid conflicts between the propagated vtkPackages.hdf5
  # and the input hdf5 used by most downstream packages,
  # we set mpiSupport to false by default.
  mpiSupport ? false,
  pythonSupport ? false,
  tkSupport ? pythonSupport,
  smpToolsBackend ? if stdenv.hostPlatform.isLinux then "TBB" else "STDThread",
  preferGLES ? false,

  # passthru.tests
  testers,
}:
assert tkSupport -> pythonSupport;
assert lib.assertMsg (builtins.elem smpToolsBackend [
  "Sequential"
  "STDThread"
  "OpenMP"
  "TBB"
]) "smpToolsBackend must be one of Sequential, STDThread, OpenMP and TBB";
let
  qtPackages =
    if withQt6 then
      qt6
    else if withQt5 then
      qt5
    else
      null;
  vtkPackages = lib.makeScope newScope (self: {
    inherit
      tbb
      mpi
      mpiSupport
      python3Packages
      pythonSupport
      ;

    hdf5 = hdf5.override {
      inherit mpi mpiSupport;
      cppSupport = !mpiSupport;
    };
    openvdb = self.callPackage openvdb.override { };
    netcdf = self.callPackage netcdf.override { };
    catalyst = self.callPackage catalyst.override { };
    adios2 = self.callPackage adios2.override { };
  });
  vtkBool = feature: bool: lib.cmakeFeature feature "${if bool then "YES" else "NO"}";
  # While char_traits<uint8_t> is not officially supported by any C++
  # standard, gcc and libcxx(<19) have extensions to support the type. The
  # C++20 standard introduces support for char_traits<char8_t>.
  # Starting with libcxx-19, the extensions to support char_traits<T> where
  # T is not a type specified by a C++ standard has been dropped. See
  # https://reviews.llvm.org/D138307 for details.
  buildStdenv = if stdenv.cc.isClang then llvmPackages_18.stdenv else stdenv;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "vtk";
  version = "9.5.0.rc2";

  srcs =
    [
      (fetchurl {
        url = "https://www.vtk.org/files/release/${lib.versions.majorMinor finalAttrs.version}/VTK-${finalAttrs.version}.tar.gz";
        hash = "sha256-US1T9x3BciDYnerl2D9XktPPfIwr3wlqdtjAexZPHkw=";
      })
    ]
    ++ lib.optionals finalAttrs.finalPackage.doCheck [
      (fetchurl {
        url = "https://www.vtk.org/files/release/${lib.versions.majorMinor finalAttrs.version}/VTKData-${finalAttrs.version}.tar.gz";
        hash = "sha256-dbY/TYGD/QeNchcOY+7EgCwgSfZ/upGtA99RciShl6Y=";
      })
    ];

  postPatch =
    ''
      substituteInPlace Wrapping/Python/vtkmodules/tk/vtkLoadPythonTkWidgets.py \
        --replace-fail 'filename = prefix+name+extension' 'filename = prefix+modname+extension'
    ''
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      sed -i '/set(VTK_USE_X "@VTK_USE_X@")/a set(VTK_USE_COCOA "@VTK_USE_COCOA@")' CMake/vtk-config.cmake.in
    '';

  nativeBuildInputs =
    [
      cmake
      pkg-config # required for finding MySQl
    ]
    ++ lib.optionals pythonSupport [
      python3Packages.python
      python3Packages.pythonImportsCheckHook
    ];

  buildInputs =
    [
      libLAS
      libgeotiff
      laszip_2
      gdal
      pdal
      alembic
      imath
      c-blosc
      tbb # should be propagated by openvdb
      unixODBC
      postgresql
      libmysqlclient
      ffmpeg
      opencascade-occt
      fontconfig
      openturns
      libarchive
      libGL
      vtkPackages.openvdb
    ]
    ++ lib.optionals finalAttrs.finalPackage.doCheck [
      libGLU
      libglut
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      libXfixes
      libXrender
      libXcursor
    ]
    ++ lib.optionals (withQt5 || withQt6) [
      qtPackages.qttools
      qtPackages.qtdeclarative
    ]
    ++ lib.optional mpiSupport mpi
    ++ lib.optional tkSupport tk;

  # propagated by vtk-config.cmake
  propagatedBuildInputs =
    [
      eigen
      boost
      verdict
      double-conversion
      freetype
      lz4
      xz
      zlib
      expat
      exprtk
      pugixml
      jsoncpp
      libxml2
      utf8cpp
      nlohmann_json
      libjpeg
      libpng
      libtiff
      proj
      sqlite
      libogg
      libharu
      libtheora
      cli11
      openslide
      vtkPackages.hdf5
      vtkPackages.adios2
      vtkPackages.netcdf
      vtkPackages.catalyst
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      tbb
      libX11
      gl2ps
    ]
    # create meta package providing dist-info for python3Pacakges.vtk that common cmake build does not do
    ++ lib.optionals pythonSupport [
      (python3Packages.mkPythonMetaPackage {
        inherit (finalAttrs) pname version meta;
        dependencies =
          with python3Packages;
          [
            wslink
            numpy
            matplotlib
          ]
          ++ lib.optional mpiSupport (mpi4py.override { inherit mpi; });
      })
    ];

  # wrapper script calls qmlplugindump, crashes due to lack of minimal platform plugin
  # Could not find the Qt platform plugin "minimal" in ""
  preConfigure = lib.optionalString withQt5 ''
    export QT_PLUGIN_PATH=${lib.getBin qt5.qtbase}/${qt5.qtbase.qtPluginPrefix}
  '';

  env.CMAKE_PREFIX_PATH = "${lib.getDev openvdb}/lib/cmake/OpenVDB";

  cmakeFlags =
    [
      (lib.cmakeFeature "CMAKE_INSTALL_BINDIR" "bin")
      (lib.cmakeFeature "CMAKE_INSTALL_LIBDIR" "lib")
      (lib.cmakeFeature "CMAKE_INSTALL_INCLUDEDIR" "include")

      # vtk common configure options
      (lib.cmakeBool "VTK_DISPATCH_SOA_ARRAYS" true)
      (lib.cmakeBool "VTK_ENABLE_CATALYST" true)
      (lib.cmakeBool "VTK_WRAP_SERIALIZATION" true)
      (lib.cmakeBool "VTK_BUILD_ALL_MODULES" true)
      (lib.cmakeBool "VTK_VERSIONED_INSTALL" false)
      (lib.cmakeFeature "VTK_SMP_IMPLEMENTATION_TYPE" smpToolsBackend)

      # use system packages if possible
      (lib.cmakeBool "VTK_USE_EXTERNAL" true)
      (lib.cmakeBool "VTK_MODULE_USE_EXTERNAL_VTK_fast_float" false) # required version incompatible
      (lib.cmakeBool "VTK_MODULE_USE_EXTERNAL_VTK_pegtl" false) # required version incompatible
      (lib.cmakeBool "VTK_MODULE_USE_EXTERNAL_VTK_cgns" false) # missing in nixpkgs
      (lib.cmakeBool "VTK_MODULE_USE_EXTERNAL_VTK_ioss" false) # missing in nixpkgs
      (lib.cmakeBool "VTK_MODULE_USE_EXTERNAL_VTK_token" false) # missing in nixpkgs
      (lib.cmakeBool "VTK_MODULE_USE_EXTERNAL_VTK_fmt" false) # prefer vendored fmt
      (lib.cmakeBool "VTK_MODULE_USE_EXTERNAL_VTK_scn" false) # missing in nixpkgs
      (lib.cmakeBool "VTK_MODULE_USE_EXTERNAL_VTK_vtkviskores" false) # missing in nixpkgs
      (lib.cmakeBool "VTK_MODULE_USE_EXTERNAL_VTK_gl2ps" stdenv.hostPlatform.isLinux) # external gl2ps causes failure linking to macOS OpenGL.framework

      # Rendering
      (vtkBool "VTK_MODULE_ENABLE_VTK_RenderingRayTracing" false) # ospray
      (vtkBool "VTK_MODULE_ENABLE_VTK_RenderingOpenXR" false) # openxr
      (vtkBool "VTK_MODULE_ENABLE_VTK_RenderingOpenVR" false) # openvr
      (vtkBool "VTK_MODULE_ENABLE_VTK_RenderingAnari" false) # anari

      # qtSupport
      (vtkBool "VTK_GROUP_ENABLE_Qt" (withQt6 || withQt5))
      (lib.cmakeFeature "VTK_QT_VERSION" "Auto") # will search for Qt6 first

      # tkSupport
      (lib.cmakeBool "VTK_USE_TK" tkSupport)
      (vtkBool "VTK_GROUP_ENABLE_Tk" tkSupport)

      # pythonSupport
      (lib.cmakeBool "VTK_WRAP_PYTHON" pythonSupport)
      (lib.cmakeBool "VTK_BUILD_PYI_FILES" pythonSupport)
      (lib.cmakeFeature "VTK_PYTHON_VERSION" "3")

      # mpiSupport
      (lib.cmakeBool "VTK_USE_MPI" mpiSupport)
      (vtkBool "VTK_GROUP_ENABLE_MPI" mpiSupport)
    ]
    ++ lib.optionals preferGLES [
      (vtkBool "VTK_MODULE_ENABLE_VTK_RenderingExternal" false)
      (vtkBool "VTK_MODULE_ENABLE_VTK_RenderingVR" false)
      (lib.cmakeBool "VTK_OPENGL_USE_GLES" true)
    ]
    ++ lib.optionals finalAttrs.finalPackage.doCheck [
      (lib.cmakeFeature "VTK_BUILD_TESTING" "ON")
    ];

  preCheck =
    lib.optionalString (withQt5 || withQt6) ''
      export QML2_IMPORT_PATH=${lib.getBin qtPackages.qtdeclarative}/${qtPackages.qtbase.qtQmlPrefix}
    ''
    # libvtkglad.so will find and load libGL.so at runtime.
    + lib.optionalString stdenv.hostPlatform.isLinux ''
      patchelf --add-rpath ${lib.getLib libGL}/lib lib/libvtkglad${stdenv.hostPlatform.extensions.sharedLibrary}
    '';

  __darwinAllowLocalNetworking = finalAttrs.finalPackage.doCheck && mpiSupport;

  nativeCheckInputs = [
    ctestCheckHook
    headlessDisplayHook2
  ] ++ lib.optional mpiSupport mpiCheckPhaseHook;

  # tests are done in passthru.tests.withCheck
  doCheck = false;

  # byte-compile python modules since the CMake build does not do it
  postInstall = lib.optionalString pythonSupport ''
    python -m compileall -s $out $out/${python3Packages.python.sitePackages}
  '';

  pythonImportsCheck = [ "vtk" ];

  dontWrapQtApps = true;

  postFixup =
    # remove thirdparty cmake patches
    ''
      rm -rf $out/lib/cmake/vtk/patches
    ''
    + lib.optionalString stdenv.hostPlatform.isLinux ''
      patchelf --add-rpath ${lib.getLib libGL}/lib $out/lib/libvtkglad${stdenv.hostPlatform.extensions.sharedLibrary}
    '';

  passthru = {
    inherit
      pythonSupport
      mpiSupport
      tkSupport
      ;

    vtkPackages = vtkPackages.overrideScope (
      final: prev: {
        vtk = finalAttrs.finalPackage;
      }
    );

    tests = {
      cmake-config = testers.hasCmakeConfigModules {
        moduleNames = [ "VTK" ];
        package = finalAttrs.finalPackage;
      };
      withCheck = finalAttrs.finalPackage.overrideAttrs {
        doCheck = true;

        nativeBuildInputs = lib.optional (withQt5 || withQt6) [
          qtPackages.qttools
          qtPackages.wrapQtAppsHook
        ];

        disabledTests = [
          # the test fails and is visually not acceptable
          "VTK::RenderingExternalCxx-TestGLUTRenderWindow"
          # the test fails but is visually acceptable
          "VTK::InteractionWidgetsPython-TestTensorWidget2"
          # outputs uniform font style throughout (expect regular, italic, bold, bold-italic)
          "VTK::RenderingFreeTypeFontConfigCxx-TestSystemFontRendering"
        ];
      };
    };
  };

  requiredSystemFeatures = [ "big-parallel" ];

  meta = {
    description = "Open source libraries for 3D computer graphics, image processing and visualization";
    homepage = "https://www.vtk.org/";
    changelog = "https://docs.vtk.org/en/latest/release_details/${lib.versions.majorMinor finalAttrs.version}.html";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ qbisi ];
    platforms = lib.platforms.unix;
    broken = smpToolsBackend == "OpenMP";
  };
})
