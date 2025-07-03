{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  llvmPackages,
  tbb,
  mpi,
  mpiCheckPhaseHook,
  mpiSupport ? true,
  testers,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "viskores";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "viskores";
    repo = "viskores";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jKuDM/NPfbMIfNpDNsDpmXdKuVobsr3s9+iht1zBLvI=";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  propagatedBuildInputs =
    [
      tbb
    ]
    ++ lib.optional mpiSupport mpi
    ++ lib.optional stdenv.cc.isClang llvmPackages.openmp;

  cmakeFlags = [
    (lib.cmakeBool "Viskores_ENABLE_OPENMP" true)
    (lib.cmakeBool "Viskores_ENABLE_TBB" true)
    (lib.cmakeBool "Viskores_ENABLE_MPI" mpiSupport)
    (lib.cmakeBool "Viskores_USE_DEFAULT_TYPES_FOR_VTK" true)
    (lib.cmakeFeature "Viskores_INSTALL_INCLUDE_DIR" "include")
    (lib.cmakeFeature "Viskores_INSTALL_CONFIG_DIR" "lib/cmake/viskores")
    (lib.cmakeFeature "Viskores_INSTALL_SHARE_DIR" "share/viskores")
  ];

  passthru.tests.cmake-config = testers.hasCmakeConfigModules {
    moduleNames = [ "Viskores" ];
    package = finalAttrs.finalPackage;
  };

  meta = {
    description = "Scalable Library for Eigenvalue Problem Computations";
    homepage = "https://github.com/Viskores/viskores";
    changelog = "https://github.com/Viskores/viskores/releases/tag/${finalAttrs.src.tag}";
    license = with lib.licenses; [ free ];
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ qbisi ];
  };
})
