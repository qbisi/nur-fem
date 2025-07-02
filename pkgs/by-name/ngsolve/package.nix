{
  lib,
  stdenv,
  fetchFromGitHub,
  replaceVars,
  cmake,
  gfortran,
  pkg-config,
  makeWrapper,
  python3Packages,
  netgen,
  mpi,
  blas,
  lapack,
  mumps-mpi,
  hypre,
  suitesparse,
  catch2,
  mpiCheckPhaseHook,
  avxSupport ? netgen.avxSupport,
  avx2Support ? netgen.avx2Support,
  avx512Support ? netgen.avx512Support,
  advSimdSupport ? false,
}:
assert advSimdSupport -> stdenv.hostPlatform.isAarch64;
let
  ngscxxInclude = toString [
    "-I${python3Packages.pybind11}/include"
    "-I${netgen}/include"
    "-I${netgen}/include/include"
  ];
  ngsldFlags = toString [
    "-L${netgen}/lib"
    "-L${mumps-mpi}/lib"
    "-L${suitesparse}/lib"
  ];
  archFlags = toString (
    lib.optional avxSupport "-mavx"
    ++ lib.optional avx2Support "-mavx2"
    ++ lib.optional avx512Support "-mavx512"
    ++ lib.optional advSimdSupport "-march=armv8.3-a+simd"
  );
  dependcies = [
    python3Packages.scipy
    (python3Packages.toPythonModule netgen)
  ];
  wrapPythonPath = "${placeholder "out"}/${python3Packages.python.sitePackages}:${python3Packages.makePythonPath dependcies}";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "ngsolve";
  version = "6.2.2501";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "ngsolve";
    repo = "ngsolve";
    tag = "v${finalAttrs.version}";
    hash = "sha256-COba5y18i8PRcm3nmQDEB+H+2cbdA32wqMtxzCPOdO8=";
  };

  patches = [
    # Add neccessary python path for standalone gui app netgen.
    ./tcl-script-add-python-path.patch
    # looks for a shared mumps library
    ./fix-find-mumps.patch

    ./add-darwin-support.patch
  ];

  postPatch =
    ''
      sed -i "2i #include <paralleldofs.hpp>" comp/hypre_precond.hpp

      substituteInPlace cmake/generate_version_file.cmake \
        --replace-fail "Git REQUIRED" "Git"

      echo "v${finalAttrs.version}-0" > version.txt

      echo -e "add_custom_target(project_catch)" > cmake/external_projects/catch.cmake

      echo -e "\nfrom mpi4py import MPI" >> tests/pytest/conftest.py

      substituteInPlace py_tutorials/mixed.py tests/pytest/test_periodic.py \
        --replace-fail "fes.FreeDofs()" "fes.FreeDofs(),inverse='umfpack'"

      substituteInPlace python/CMakeLists.txt \
        --replace-fail ''\'''${CMAKE_INSTALL_PREFIX}/''${NGSOLVE_INSTALL_DIR_PYTHON}' \
                       ''\'''${CMAKE_INSTALL_PREFIX}/''${NGSOLVE_INSTALL_DIR_PYTHON}:$ENV{PYTHONPATH}'

      substituteInPlace CMakeLists.txt \
        --replace-fail "set(NGS_TEST_TIMEOUT 60)" "set(NGS_TEST_TIMEOUT 300)"

      substituteInPlace ngsolve.tcl \
        --replace-fail "@WRAP_PYTHONPATH@" "${wrapPythonPath}"
    ''
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      substituteInPlace comp/CMakeLists.txt --replace-fail \
        ''\'''${HYPRE_LIBRARIES}' \
        ''\'''${HYPRE_LIBRARIES} "-Wl,-rpath,${lib.getLib hypre}/lib"'
    '';

  nativeBuildInputs = [
    cmake
    gfortran
    pkg-config
    python3Packages.pybind11-stubgen
    makeWrapper
  ];

  cmakeFlags = [
    (lib.cmakeFeature "ngscxx_includes" ngscxxInclude)
    (lib.cmakeFeature "ngsld_flags" ngsldFlags)
    (lib.cmakeFeature "CMAKE_CXX_FLAGS" archFlags)
    (lib.cmakeFeature "NETGEN_DIR" "${netgen}")
    (lib.cmakeFeature "CATCH_INCLUDE_DIR" "${catch2}/include/catch2")
    (lib.cmakeBool "BUILD_SHARED_LIBS" (!stdenv.hostPlatform.isStatic))
    (lib.cmakeBool "BLA_PREFER_PKGCONFIG" true)
    (lib.cmakeBool "USE_MPI" true)
    (lib.cmakeBool "USE_HYPRE" true)
    (lib.cmakeBool "USE_MUMPS" true)
    (lib.cmakeBool "USE_SUPERBUILD" false)
    (lib.cmakeBool "BUILD_STUB_FILES" true)
    (lib.cmakeBool "BUILD_TESTING" finalAttrs.finalPackage.doInstallCheck)
    (lib.cmakeBool "ENABLE_UNIT_TESTS" finalAttrs.finalPackage.doInstallCheck)
  ];

  buildInputs = [
    blas
    lapack
    hypre
    mumps-mpi
    suitesparse
    mpi
  ];

  propagatedBuildInputs = dependcies;

  propagatedUserEnvPkgs = [ netgen ];

  # Ngsolve.tcl is a tcl script to be sourced by netgen and share not be binary wrapped.
  # It should not be placed in bin directory as python-env will wrap every executable in bin.
  # We move it into $out/libexec and netgen will look for ngsolve.tcl in dir/../libexec for each dir in $PATH.
  postFixup = ''
    mkdir $out/libexec
    mv $out/bin/ngsolve.tcl $out/libexec
    wrapProgram  $out/bin/ngspy --set PYTHONPATH "${wrapPythonPath}:\$PYTHONPATH"
  '';

  __darwinAllowLocalNetworking = true;

  doInstallCheck = true;

  installCheckTarget = "test";

  # Test on ngscxx/ngsld that they can compile/link without NIX_CFLAGS_COMPILE/NIX_LDFLAGS
  preInstallCheck = ''
    unset NIX_CFLAGS_COMPILE
    unset NIX_LDFLAGS
    export PYTHONPATH=$out/${python3Packages.python.sitePackages}:$PYTHONPATH
    export PATH=$out/bin:$PATH
  '';

  nativeInstallCheckInputs = [
    catch2
    python3Packages.pytest
    python3Packages.pythonImportsCheckHook
    mpiCheckPhaseHook
  ];

  pythonImportsCheck = [ "ngsolve" ];

  meta = {
    homepage = "https://ngsolve.org";
    downloadPage = "https://github.com/NGSolve/ngsolve";
    description = "Multi-purpose finite element library";
    license = lib.licenses.lgpl21Only;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ qbisi ];
  };
})
