{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  configuration,
  kernel,
  medcoupling,
  mpi,
  libtirpc,
  python3Packages,
  pkg-config,
  cppunit,
  guiSupport,
  mpiSupport,
  testers,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "salome-med";
  version = "9.14.0";

  src = fetchFromGitHub {
    owner = "SalomePlatform";
    repo = "med";
    tag = "V${lib.concatStringsSep "_" (lib.versions.splitVersion finalAttrs.version)}";
    hash = "sha256-VgZAecjNZp4b5xUCwXmf8/p+YrN4X33k15w1ydXToSw=";
  };

  nativeBuildInputs = [
    cmake
    kernel
    configuration
    python3Packages.python
  ];

  buildInputs = [
    medcoupling
    mpi
    libtirpc
  ];

  # propagatedBuildInputs = [
  #   python3Packages.scipy
  # ];

  cmakeFlags = [
    (lib.cmakeBool "SALOME_BUILD_TESTS" finalAttrs.finalPackage.doCheck)
    (lib.cmakeBool "SALOME_BUILD_DOC" false)
    (lib.cmakeBool "SALOME_BUILD_GUI" guiSupport)
    (lib.cmakeBool "SALOME_USE_MPI" mpiSupport)
    (lib.cmakeBool "SALOME_FIELDS_WITH_FILE_EXAMPLES" false)

  ];

  doCheck = false;

  nativeCheckInputs = [
    pkg-config
    cppunit
  ];

  passthru.tests = {
    cmake-config = testers.hasCmakeConfigModules {
      moduleNames = [ "SalomeGEOM" ];
      package = finalAttrs.finalPackage;
    };
  };

  meta = {
    description = "SALOME platform standard file for meshes and fields";
    homepage = "https://www.salome-platform.org";
    downloadPage = "https://github.com/SalomePlatform/med ";
    license = with lib.licenses; [ lgpl21Plus ];
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ qbisi ];
  };
})
