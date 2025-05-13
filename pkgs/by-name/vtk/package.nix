{
  lib,
  stdenv,
  fetchurl,
  fetchpatch2,
  cmake,
  mpi,

  double-conversion,
  verdict,
  libarchive,
  fmt,

  lz4,
  pugixml,
  xz,
  zlib,

  libjpeg,
  libpng,
  libtiff,
  expat,
  jsoncpp,
  libxml2,

  exprtk,

  boost,
  cli11,
  eigen,
  nlohmann_json,
  utf8cpp,

  proj,
  gl2ps,
  hdf5,
  netcdf,
  libharu,
  libogg,
  libtheora,
  freetype,
  fontconfig,

  sqlite,
  tbb_2022_0,
  llvmPackages,

  libGL,
  libX11,
  libXcursor,
  apple-sdk_12,
  qt5,
  qt6,
  python3Packages,

  # custom options
  mpiSupport ? true,
  qtVersion ? 6,
  enableEgl ? !stdenv.hostPlatform.isDarwin,
  enablePython ? true,
  # Use GLES instead of GL, some platforms have better support for one than the other
  preferGLES ? stdenv.hostPlatform.isAarch && !stdenv.hostPlatform.isDarwin,
}:
assert enableEgl -> !stdenv.hostPlatform.isDarwin;

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
      inherit python3Packages mpi mpiSupport;
      hdf5 = hdf5.override {
        inherit mpi mpiSupport;
        cppSupport = !mpiSupport;
      };
      netcdf = final.callPackage netcdf.override { };
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
    # (fetchpatch2 {
    #   url = "https://gitlab.archlinux.org/archlinux/packaging/packages/vtk/-/raw/6363b17dcc573d3d767d9b8039bb4dfbbdd5860a/fix-gcc-15.patch?full_index=1";
    #   hash = "sha256-vvvj+fzaPGCChu9hpaXfM53q//KkNs4rLsiqtyZWcOg=";
    # })
  ];

  postPatch = ''
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
      double-conversion
      verdict
      libarchive
      fmt

      lz4
      pugixml
      xz
      zlib

      libjpeg
      libpng
      libtiff
      expat
      jsoncpp
      libxml2

      exprtk

      boost
      cli11
      eigen
      nlohmann_json
      utf8cpp

      proj
      libharu
      libogg
      libtheora
      freetype
      fontconfig

      tbb_2022_0

      sqlite
      vtkPackages.hdf5
      vtkPackages.netcdf
      vtkPackages.qttools
      vtkPackages.qtdeclarative
    ]
    ++ lib.optional mpiSupport mpi
    ++ lib.optional stdenv.cc.isClang llvmPackages.openmp
    ++ lib.optional stdenv.hostPlatform.isDarwin apple-sdk_12;

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
      # (lib.cmakeBool "VTK_BUILD_ALL_MODULES" true)
      (lib.cmakeBool "VTK_USE_MPI" mpiSupport)
      (lib.cmakeBool "VTK_OPENGL_USE_GLES" preferGLES)
      (lib.cmakeBool "VTK_OPENGL_HAS_EGL" enableEgl)
      (lib.cmakeBool "VTK_USE_EXTERNAL" true)
      (lib.cmakeBool "VTK_MODULE_USE_EXTERNAL_VTK_fast_float" false) # version incompatible
      (lib.cmakeBool "VTK_MODULE_USE_EXTERNAL_VTK_pegtl" false) # version incompatible
      (lib.cmakeBool "VTK_MODULE_USE_EXTERNAL_VTK_cgns" false) # missing in nixpkgs
      (lib.cmakeBool "VTK_MODULE_USE_EXTERNAL_VTK_ioss" false) # missing in nixpkgs
      (lib.cmakeBool "VTK_MODULE_USE_EXTERNAL_VTK_token" false) # missing in nixpkgs
      (lib.cmakeBool "VTK_MODULE_USE_EXTERNAL_VTK_gl2ps" (!stdenv.hostPlatform.isDarwin)) # External gl2ps causes failure linking to macOS OpenGL.framework
      (lib.cmakeBool "VTK_SMP_ENABLE_SEQUENTIAL" true)
      (lib.cmakeBool "VTK_SMP_ENABLE_STDTHREAD" true)
      (lib.cmakeBool "VTK_SMP_ENABLE_TBB" true)
      (lib.cmakeBool "VTK_SMP_ENABLE_OPENMP" true)
      (lib.cmakeFeature "VTK_SMP_IMPLEMENTATION_TYPE" "TBB")
      (lib.cmakeFeature "CMAKE_INSTALL_BINDIR" "bin")
      (lib.cmakeFeature "CMAKE_INSTALL_LIBDIR" "lib")
      (lib.cmakeFeature "CMAKE_INSTALL_INCLUDEDIR" "include")
      (lib.cmakeFeature "VTK_GROUP_ENABLE_Qt" "YES")
      (lib.cmakeFeature "VTK_QT_VERSION" (toString qtVersion))
    ]
    ++ lib.optionals enablePython [
      (lib.cmakeBool "VTK_WRAP_PYTHON" true)
      # (lib.cmakeBool "VTK_BUILD_PYI_FILES" true)
      (lib.cmakeFeature "VTK_PYTHON_VERSION" "3")
    ];

  # byte-compile python modules since the CMake build does not do it
  postInstall = lib.optionalString (enablePython && stdenv.hostPlatform.isDarwin) ''
    python -m compileall -s $out $out/${python3Packages.python.sitePackages}
  '';

  dontWrapQtApps = true;

  postFixup = lib.optionalString (!stdenv.hostPlatform.isDarwin) ''
    patchelf --add-rpath ${lib.getLib libGL}/lib $out/lib/libvtkglad${stdenv.hostPlatform.extensions.sharedLibrary}
  '';

  passthru = {
    inherit
      qtVersion
      enableEgl
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
    maintainers = with lib.maintainers; [
      qbisi
    ];
    platforms = lib.platforms.unix;
    broken = stdenv.hostPlatform.isDarwin;
  };
})
