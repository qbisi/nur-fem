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
  mpi,
  python3Packages,
  fmt,
  boost,
  eigen,
  cli11,
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
  nlohmann_json,

  # io modules
  adios2,
  libLAS,
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
  qt5,
  qt6,

  # check
  ctestCheckHook,
  headlessDisplayHook,
  mpiCheckPhaseHook,

  # custom options
  withQt5 ? false,
  withQt6 ? false,
  # To avoid conflicts between the propagated vtkPackages.hdf5
  # and the input hdf5 used by most downstream packages,
  # we set mpiSupport to false by default.
  mpiSupport ? false,
  pythonSupport ? false,

  # passthru.tests
  testers,
}:
let
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
    adios2 = self.callPackage adios2.override { };
  });
  # While char_traits<uint8_t> is not officially supported by any C++
  # standard, gcc and libcxx(<19) have extensions to support the type. The
  # C++20 standard introduces support for char_traits<char8_t>.
  # Starting with libcxx-19, the extensions to support char_traits<T> where
  # T is not a type specified by a C++ standard has been dropped. See
  # https://reviews.llvm.org/D138307 for details.
  buildStdenv = if stdenv.cc.isClang then llvmPackages_18.stdenv else stdenv;
in
buildStdenv.mkDerivation (finalAttrs: {
  pname = "vtk";
  version = "9.4.2";

  srcs =
    [
      (fetchurl {
        url = "https://www.vtk.org/files/release/${lib.versions.majorMinor finalAttrs.version}/VTK-${finalAttrs.version}.tar.gz";
        hash = "sha256-NsmODalrsSow/lNwgJeqlJLntm1cOzZuHI3CUeKFagI=";
      })
    ]
    ++ lib.optionals finalAttrs.finalPackage.doCheck [
      (fetchurl {
        url = "https://www.vtk.org/files/release/${lib.versions.majorMinor finalAttrs.version}/VTKData-${finalAttrs.version}.tar.gz";
        hash = "sha256-Hgqj32POOXXSnutmmF/DczMIJPkMKZG+UpUa0qgkGxE=";
      })
    ];

  patches = [
    (fetchpatch2 {
      url = "https://gitlab.archlinux.org/archlinux/packaging/packages/vtk/-/raw/b4d07bd7ee5917e2c32f7f056cf78472bcf1cec2/netcdf-4.9.3.patch?full_index=1";
      hash = "sha256-h1NVeLuwAj7eUG/WSvrpXN9PtpjFQ/lzXmJncwY0r7w=";
    })
  ];

  postPatch = ''
    substituteInPlace Filters/Sources/Testing/Cxx/TestHyperTreeGridSourceDistributed.cxx \
      --replace-fail "<char, NbTrees>" "<signed char, NbTrees>"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config # required for finding MySQl
  ] ++ lib.optional pythonSupport python3Packages.python;

  buildInputs = [
    libLAS
    gdal
    pdal
    alembic
    imath # should be propagated by alembic
    vtkPackages.openvdb
    c-blosc # should be propagated by openvdb
    tbb # should be propagated by openvdb
    unixODBC
    postgresql
    libmysqlclient
    ffmpeg
    opencascade-occt
    cli11
    fontconfig
    libGL
  ] ++ lib.optional mpiSupport mpi;

  # propagated by vtk-config.cmake
  propagatedBuildInputs =
    [
      fmt
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
      vtkPackages.hdf5
      vtkPackages.adios2
      vtkPackages.netcdf
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      tbb
      libX11
      gl2ps
    ]
    ++ lib.optionals withQt5 [
      qt5.qttools
      qt5.qtdeclarative
    ]
    ++ lib.optionals withQt6 [
      qt6.qttools
      qt6.qtdeclarative
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

  cmakeFlags =
    [
      (lib.cmakeBool "VTK_VERSIONED_INSTALL" false)
      (lib.cmakeBool "VTK_USE_MPI" mpiSupport)
      (lib.cmakeBool "VTK_USE_EXTERNAL" true)
      (lib.cmakeBool "VTK_MODULE_USE_EXTERNAL_VTK_fast_float" false) # required version incompatible
      (lib.cmakeBool "VTK_MODULE_USE_EXTERNAL_VTK_pegtl" false) # required version incompatible
      (lib.cmakeBool "VTK_MODULE_USE_EXTERNAL_VTK_cgns" false) # missing in nixpkgs
      (lib.cmakeBool "VTK_MODULE_USE_EXTERNAL_VTK_ioss" false) # missing in nixpkgs
      (lib.cmakeBool "VTK_MODULE_USE_EXTERNAL_VTK_token" false) # missing in nixpkgs
      (lib.cmakeBool "VTK_MODULE_USE_EXTERNAL_VTK_xdmf2" false) # missing in nixpkgs
      (lib.cmakeBool "VTK_MODULE_USE_EXTERNAL_VTK_xdmf3" false) # missing in nixpkgs
      (lib.cmakeBool "VTK_MODULE_USE_EXTERNAL_VTK_gl2ps" stdenv.hostPlatform.isLinux) # External gl2ps causes failure linking to macOS OpenGL.framework
      (lib.cmakeFeature "CMAKE_MODULE_PATH" "${lib.getDev openvdb}/lib/cmake/OpenVDB") # provide FindOpenVDB.cmake
      (lib.cmakeFeature "PostgreSQL_ROOT" "${lib.getDev postgresql};${lib.getLib postgresql}") # postgresql
      (lib.cmakeFeature "VTK_MODULE_ENABLE_VTK_IOADIOS2" "YES") # adios2
      (lib.cmakeFeature "VTK_MODULE_ENABLE_VTK_fides" "YES") # adios2
      (lib.cmakeFeature "VTK_MODULE_ENABLE_VTK_IOLAS" "YES") # libLAS
      (lib.cmakeFeature "VTK_MODULE_ENABLE_VTK_GeovisGDAL" "YES") # gdal
      (lib.cmakeFeature "VTK_MODULE_ENABLE_VTK_IOGDAL" "YES") # gdal
      (lib.cmakeFeature "VTK_MODULE_ENABLE_VTK_IOPDAL" "YES") # pdal
      (lib.cmakeFeature "VTK_MODULE_ENABLE_VTK_IOAlembic" "YES") # alembic
      (lib.cmakeFeature "VTK_MODULE_ENABLE_VTK_IOOpenVDB" "YES") # openvdb
      (lib.cmakeFeature "VTK_MODULE_ENABLE_VTK_IOODBC" "YES") # unixodbc
      (lib.cmakeFeature "VTK_MODULE_ENABLE_VTK_IOPostgreSQL" "YES") # postgresql
      (lib.cmakeFeature "VTK_MODULE_ENABLE_VTK_IOMySQL" "YES") # mariadb
      (lib.cmakeFeature "VTK_MODULE_ENABLE_VTK_IOCATALYST" "NO") # catalyst, missing in nixpkgs
      (lib.cmakeFeature "VTK_MODULE_ENABLE_VTK_IOOCCT" "YES") # opencascade-occt
      (lib.cmakeFeature "VTK_MODULE_ENABLE_VTK_IOFFMPEG" "YES") # ffmpeg
      (lib.cmakeFeature "VTK_MODULE_ENABLE_VTK_IOMotionFX" "YES") # builtin
      (lib.cmakeFeature "VTK_MODULE_ENABLE_VTK_IOXdmf2" "YES") # vendored
      (lib.cmakeFeature "VTK_MODULE_ENABLE_VTK_IOXdmf3" "YES") # vendored
      (lib.cmakeFeature "CMAKE_INSTALL_BINDIR" "bin")
      (lib.cmakeFeature "CMAKE_INSTALL_LIBDIR" "lib")
      (lib.cmakeFeature "CMAKE_INSTALL_INCLUDEDIR" "include")
      # `VTK_SMP_IMPLEMENTATION_TYPE` can be one of Sequential, OpenMP, TBB, and STDThread.
      (lib.cmakeFeature "VTK_SMP_IMPLEMENTATION_TYPE" (
        if stdenv.hostPlatform.isLinux then "TBB" else "STDThread"
      ))
    ]
    ++ lib.optionals (withQt6 || withQt5) [
      (lib.cmakeFeature "VTK_GROUP_ENABLE_Qt" "YES")
      (lib.cmakeFeature "VTK_QT_VERSION" "Auto") # will search for Qt6 first
    ]
    ++ lib.optionals pythonSupport [
      (lib.cmakeBool "VTK_WRAP_PYTHON" true)
      (lib.cmakeBool "VTK_BUILD_PYI_FILES" true)
      (lib.cmakeFeature "VTK_PYTHON_VERSION" "3")
      (lib.cmakeFeature "VTK_MODULE_ENABLE_VTK_WebPython" "YES")
    ]
    ++ lib.optionals finalAttrs.finalPackage.doCheck [
      (lib.cmakeFeature "VTK_BUILD_TESTING" "ON")
    ];

  preCheck =
    lib.optionalString withQt5 ''
      export QML2_IMPORT_PATH=${lib.getBin qt5.qtdeclarative}/${qt5.qtbase.qtQmlPrefix}
    ''
    + lib.optionalString withQt6 ''
      export QML2_IMPORT_PATH=${lib.getBin qt6.qtdeclarative}/${qt6.qtbase.qtQmlPrefix}
    ''
    # libvtkglad.so will find and load libGL.so at runtime.
    + lib.optionalString stdenv.hostPlatform.isLinux ''
      patchelf --add-rpath ${lib.getLib libGL}/lib lib/libvtkglad${stdenv.hostPlatform.extensions.sharedLibrary}
    '';

  __darwinAllowLocalNetworking = finalAttrs.finalPackage.doCheck && mpiSupport;

  nativeCheckInputs = [
    ctestCheckHook
    headlessDisplayHook
  ] ++ lib.optional mpiSupport mpiCheckPhaseHook;

  # tests are done in passthru.tests.withCheck
  doCheck = false;

  disabledTests = [
    # flaky tests
    "VTK::GUISupportQtQuickCxx-TestQQuickVTKRenderItem"
    "VTK::GUISupportQtQuickCxx-TestQQuickVTKRenderItemWidget"
    "VTK::GUISupportQtQuickCxx-TestQQuickVTKRenderWindow"
    "VTK::InteractionWidgetsPython-TestTensorWidget2"
    "VTK::RenderingOpenGL2Cxx-TestGlyph3DMapperPickability"
    # caught SIGSEGV/SIGTERM in mpiexec
    "VTK::FiltersParallelCxx-MPI-DistributedData"
    "VTK::FiltersParallelCxx-MPI-DistributedDataRenderPass"
    # caught SIGSEGV in _XFlush(libX11.so)
    "VTK::RenderingCoreCxx-TestCompositePolyDataMapperToggleScalarVisibilities"
    "VTK::CommonDataModelCxx-quadraticIntersection"
  ];

  # byte-compile python modules since the CMake build does not do it
  postInstall = lib.optionalString pythonSupport ''
    python -m compileall -s $out $out/${python3Packages.python.sitePackages}
  '';

  dontWrapQtApps = true;

  postFixup =
    # Remove thirdparty find module that have been provided in nixpkgs
    ''
      rm -rf $out/lib/cmake/vtk/patches
      rm $out/lib/cmake/vtk/Find{double-conversion,EXPAT,Freetype,utf8cpp,LibXml2,FontConfig}.cmake
    ''
    + lib.optionalString stdenv.hostPlatform.isLinux ''
      patchelf --add-rpath ${lib.getLib libGL}/lib $out/lib/libvtkglad${stdenv.hostPlatform.extensions.sharedLibrary}
    '';

  passthru = {
    inherit
      pythonSupport
      mpiSupport
      vtkPackages
      ;
    tests = {
      cmake-config = testers.hasCmakeConfigModules {
        moduleNames = [ "VTK" ];
        package = finalAttrs.finalPackage;
      };
      withCheck = finalAttrs.finalPackage.overrideAttrs {
        doCheck = true;
      };
    };
  };

  meta = {
    description = "Open source libraries for 3D computer graphics, image processing and visualization";
    homepage = "https://www.vtk.org/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ qbisi ];
    platforms = lib.platforms.unix;
  };
})
