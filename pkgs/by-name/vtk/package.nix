{
  lib,
  stdenv,
  fetchurl,
  fetchpatch2,
  cmake,
  python3Packages,

  # buildInputs
  mpi,
  fmt,
  eigen,
  exprtk,
  utf8cpp,
  verdict,
  nlohmann_json,
  double-conversion,

  # common data libraries
  lz4,
  xz,
  zlib,
  pugixml,
  expat,
  jsoncpp,
  libxml2,

  # io modules
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
  adios2,
  opencascade-occt,

  # threading
  llvmPackages,
  tbb_2022_0,

  # rendering
  freetype,
  libX11,
  libXcursor,
  gl2ps,
  libGL,
  qt5,
  qt6,

  # custom options
  mpiSupport ? true,
  qtVersion ? 6,
  enablePython ? true,
  preferGLES ? stdenv.hostPlatform.isAarch && !stdenv.hostPlatform.isDarwin,
}:

let
  qtPackages =
    if (qtVersion == 6) then
      qt6
    else if (qtVersion == 5) then
      qt5
    else
      throw "qtVersion must be either 5 or 6";
  vtkPackages = qtPackages.overrideScope (
    final: prev: {
      inherit
        mpi
        mpiSupport
        enablePython
        python3Packages
        ;
      python3 = python3Packages.python;
      pythonSupport = enablePython;

      hdf5 = hdf5.override {
        inherit mpi mpiSupport;
        cppSupport = !mpiSupport;
      };
      netcdf = final.callPackage netcdf.override { };
      adios2 = final.callPackage adios2.override { };
    }
  );
in
stdenv.mkDerivation (finalAttrs: {
  pname = "vtk";
  version = "9.4.2";

  src = fetchurl {
    url = "https://www.vtk.org/files/release/${lib.versions.majorMinor finalAttrs.version}/VTK-${finalAttrs.version}.tar.gz";
    hash = "sha256-NsmODalrsSow/lNwgJeqlJLntm1cOzZuHI3CUeKFagI=";
  };

  patches = [
    # (fetchpatch2 {
    #   url = "https://gitlab.archlinux.org/archlinux/packaging/packages/vtk/-/raw/3fea08744ab6a859dacb7a6b6ab26f9272a8e6d4/vtk-occt.patch?full_index=1";
    #   hash = "sha256-bQCnjFnM7qw1rgzVGPaV7tRh2yK8WYcbhIaKYwHEmC4=";
    # })
    (fetchpatch2 {
      url = "https://gitlab.archlinux.org/archlinux/packaging/packages/vtk/-/raw/b4d07bd7ee5917e2c32f7f056cf78472bcf1cec2/netcdf-4.9.3.patch?full_index=1";
      hash = "sha256-h1NVeLuwAj7eUG/WSvrpXN9PtpjFQ/lzXmJncwY0r7w=";
    })
  ];

  postPatch = lib.optionalString stdenv.cc.isClang ''
    substituteInPlace IO/Geometry/vtkGLTFDocumentLoaderInternals.cxx \
      --replace-fail "return value == extensionUsedByModel;" "return value == extensionUsedByModel.get<std::string>();" \
      --replace-fail "return value == extensionRequiredByModel;" "return value == extensionRequiredByModel.get<std::string>();"

    # CXX_STANDARD 20 is needed for clang to support template char_traits<char8_t>
    echo "vtk_module_set_properties(VTK::ParallelDIY CXX_STANDARD 20)" >> Parallel/DIY/CMakeLists.txt
    echo "vtk_module_set_properties(VTK::FiltersExtraction CXX_STANDARD 20)" >> Filters/Extraction/CMakeLists.txt
  '';

  nativeBuildInputs =
    [
      cmake
    ]
    ++ lib.optionals enablePython [
      python3Packages.python
    ];

  buildInputs =
    [
      fmt
      eigen
      exprtk
      utf8cpp
      verdict
      nlohmann_json
      double-conversion

      # common data libraries
      lz4
      xz
      zlib
      pugixml
      expat
      jsoncpp
      libxml2

      # io modules
      ffmpeg
      libjpeg
      libpng
      libtiff
      proj
      sqlite
      libogg
      libharu
      libtheora
      vtkPackages.hdf5
      vtkPackages.netcdf
      vtkPackages.adios2
      opencascade-occt

      # rendering
      freetype
      vtkPackages.qttools
      vtkPackages.qtdeclarative
    ]
    ++ lib.optional mpiSupport mpi
    ++ lib.optional stdenv.cc.isClang llvmPackages.openmp
    ++ lib.optional stdenv.hostPlatform.isLinux tbb_2022_0;

  propagatedBuildInputs =
    lib.optionals stdenv.hostPlatform.isLinux [
      libX11
      libXcursor
      gl2ps
      libGL
    ]
    # create meta package providing dist-info for python3Pacakges.vtk that common cmake build does not do
    ++ lib.optionals enablePython [
      (python3Packages.mkPythonMetaPackage {
        inherit (finalAttrs) pname version meta;
        dependencies =
          with python3Packages;
          [
            numpy
            matplotlib
          ]
          ++ lib.optional mpiSupport (mpi4py.override { inherit mpi; });
      })
    ];

  cmakeFlags =
    [
      "-Wno-dev"
      (lib.cmakeBool "VTK_VERSIONED_INSTALL" false)
      (lib.cmakeBool "VTK_USE_MPI" mpiSupport)
      (lib.cmakeBool "VTK_OPENGL_USE_GLES" preferGLES)
      (lib.cmakeBool "VTK_USE_EXTERNAL" true)
      (lib.cmakeBool "VTK_MODULE_USE_EXTERNAL_VTK_fast_float" false) # required version incompatible
      (lib.cmakeBool "VTK_MODULE_USE_EXTERNAL_VTK_pegtl" false) # required version incompatible
      (lib.cmakeBool "VTK_MODULE_USE_EXTERNAL_VTK_cgns" false) # missing in nixpkgs
      (lib.cmakeBool "VTK_MODULE_USE_EXTERNAL_VTK_ioss" false) # missing in nixpkgs
      (lib.cmakeBool "VTK_MODULE_USE_EXTERNAL_VTK_token" false) # missing in nixpkgs
      (lib.cmakeBool "VTK_MODULE_USE_EXTERNAL_VTK_gl2ps" (!stdenv.hostPlatform.isDarwin)) # External gl2ps causes failure linking to macOS OpenGL.framework
      (lib.cmakeBool "VTK_SMP_ENABLE_TBB" (!stdenv.hostPlatform.isDarwin)) # TBB cause segfault on macOS
      (lib.cmakeFeature "VTK_SMP_IMPLEMENTATION_TYPE" "OpenMP")
      (lib.cmakeFeature "VTK_MODULE_ENABLE_VTK_IOOCCT" "YES")
      (lib.cmakeFeature "VTK_MODULE_ENABLE_VTK_IOADIOS2" "YES")
      (lib.cmakeFeature "VTK_MODULE_ENABLE_VTK_IOFFMPEG" "YES")
      (lib.cmakeFeature "CMAKE_INSTALL_BINDIR" "bin")
      (lib.cmakeFeature "CMAKE_INSTALL_LIBDIR" "lib")
      (lib.cmakeFeature "CMAKE_INSTALL_INCLUDEDIR" "include")
      (lib.cmakeFeature "VTK_GROUP_ENABLE_Qt" "YES")
      (lib.cmakeFeature "VTK_QT_VERSION" (toString qtVersion))
    ]
    ++ lib.optionals enablePython [
      (lib.cmakeBool "VTK_WRAP_PYTHON" true)
      (lib.cmakeBool "VTK_BUILD_PYI_FILES" true)
      (lib.cmakeFeature "VTK_PYTHON_VERSION" "3")
    ];

  # byte-compile python modules since the CMake build does not do it
  postInstall = lib.optionalString enablePython ''
    python -m compileall -s $out $out/${python3Packages.python.sitePackages}
  '';

  dontWrapQtApps = true;

  postFixup = lib.optionalString (!stdenv.hostPlatform.isDarwin) ''
    patchelf --add-rpath ${lib.getLib libGL}/lib $out/lib/libvtkglad${stdenv.hostPlatform.extensions.sharedLibrary}
  '';

  passthru = {
    inherit
      qtVersion
      enablePython
      mpiSupport
      vtkPackages
      preferGLES
      ;
  };

  meta = {
    description = "Open source libraries for 3D computer graphics, image processing and visualization";
    homepage = "https://www.vtk.org/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ qbisi ];
    platforms = lib.platforms.unix;
  };
})
