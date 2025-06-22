{
  lib,
  stdenv,
  fetchFromGitHub,
  swig,
  cmake,
  pkg-config,
  configuration,
  libxml2,
  boost,
  omniorb,
  mpi,
  hdf5,
  python3Packages,
  cppunit,
  mpiSupport,
  testers,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "salome-kernel";
  version = "9.14.0";

  src = fetchFromGitHub {
    owner = "SalomePlatform";
    repo = "kernel";
    tag = "V${lib.concatStringsSep "_" (lib.versions.splitVersion finalAttrs.version)}";
    hash = "sha256-HXfTHmHsUotpmMZWVLKUftDXdb5ZiGTtZ737vZZ5tCw=";
  };

  patches = [
    ./add_calcium_c_interface_macros.patch
  ];

  postPatch = ''
    substituteInPlace src/DSC/DSC_Python/calcium.i \
      --replace-fail "PyArray_TYPE(a)" "PyArray_TYPE((PyArrayObject *)a)" \
      --replace-fail "PyArray_NOTYPE" "NPY_NOTYPE" \
      --replace-fail "PyArray_INT" "NPY_INT" \
      --replace-fail "PyArray_LONG" "NPY_LONG" \
      --replace-fail "PyArray_FLOAT" "NPY_FLOAT" \
      --replace-fail "PyArray_DOUBLE" "NPY_DOUBLE" \
      --replace-fail "PyArray_CFLOAT" "NPY_CFLOAT" \
      --replace-fail "PyArray_STRING" "NPY_STRING" \
      --replace-fail "PyEval_CallObject(excc, (PyObject *)NULL)" "PyObject_CallNoArgs(excc)"

    substituteInPlace SalomeKERNELConfig.cmake.in \
      --replace-fail '@SALOME_INSTALL_CMAKE@' lib/cmake/''\'''${PROJECT_NAME}' \
      --replace-fail '@SALOME_INSTALL_CMAKE_LOCAL@' lib/cmake/''\'''${PROJECT_NAME}'
  '';

  nativeBuildInputs = [
    swig
    cmake
    pkg-config
    configuration
  ];

  buildInputs = [
    libxml2
    boost
    omniorb
    hdf5
  ] ++ lib.optional mpiSupport mpi;

  propagatedBuildInputs = with python3Packages; [
    scipy
    psutil
    omniorbpy
  ];

  cmakeFlags = [
    (lib.cmakeBool "SALOME_BUILD_TESTS" finalAttrs.finalPackage.doCheck)
    (lib.cmakeBool "SALOME_BUILD_DOC" false)
    (lib.cmakeBool "SALOME_USE_MPI" mpiSupport)
    (lib.cmakeFeature "LIBXML2_LIBRARY" "xml2")
    (lib.cmakeFeature "SALOME_INSTALL_BINS" "bin")
    (lib.cmakeFeature "SALOME_INSTALL_IDLS" "idl/salome")
    (lib.cmakeFeature "SALOME_INSTALL_HEADERS" "include")
    (lib.cmakeFeature "SALOME_INSTALL_LIBS" "lib")
    (lib.cmakeFeature "SALOME_INSTALL_CMAKE" "lib/cmake/salomekernel")
    (lib.cmakeFeature "SALOME_INSTALL_AMCONFIG" "share/unix")
    (lib.cmakeFeature "SALOME_INSTALL_AMCONFIG_LOCAL" "share/unix")
  ];

  postInstall = ''
    mv $out/lib/_*.so $out/${python3Packages.python.sitePackages}
  '';

  doCheck = true;

  nativeCheckInputs = [ cppunit ];

  setupHook = ./setup-hook.sh;

  passthru.tests = {
    cmake-config = testers.hasCmakeConfigModules {
      moduleNames = [ "SalomeKERNEL" ];
      package = finalAttrs.finalPackage;
    };
  };

  meta = {
    description = "Kernel module of the SALOME platform";
    homepage = "https://www.salome-platform.org";
    downloadPage = "https://github.com/SalomePlatform/kernel";
    license = with lib.licenses; [ lgpl21Plus ];
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ qbisi ];
  };
})
