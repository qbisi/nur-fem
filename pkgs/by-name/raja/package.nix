{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  llvmPackages,
}:
stdenv.mkDerivation (finalAttrs: {
  version = "2025.03.0";
  pname = "raja";

  src = fetchFromGitHub {
    owner = "LLNL";
    repo = "RAJA";
    tag = "v${finalAttrs.version}";
    hash = "sha256-OLQC3h/BKprGkpR978LkyLpIqNj5fmyBLlry3bOczCk=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
  ] ++ lib.optional stdenv.cc.isClang llvmPackages.openmp;

  cmakeFlags = [
    (lib.cmakeBool "ENABLE_OPENMP" true)
    (lib.cmakeBool "RAJA_ENABLE_EXAMPLES" false)
    (lib.cmakeBool "RAJA_ENABLE_EXERCISES" false)
    # (lib.cmakeBool "RAJA_ENABLE_DOCUMENTATION" true)
    (lib.cmakeBool "BUILD_SHARED_LIBS" (!stdenv.hostPlatform.isStatic))
    (lib.cmakeBool "RAJA_ENABLE_TESTS" finalAttrs.finalPackage.doCheck)
  ];

  __darwinAllowLocalNetworking = true;

  doCheck = true;

  meta = {
    homepage = "https://github.com/LLNL/RAJA";
    description = "RAJA Performance Portability Layer (C++)";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ qbisi ];
  };
})
