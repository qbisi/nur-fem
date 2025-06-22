{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  swig,
  configuration,
  boost,
  libxml2,
  libtirpc,
  medfile,
  hdf5,
  mpi,
  metis,
  scotch,
  python3Packages,
  pkg-config,
  cppunit,
  ctestCheckHook,
  mpiCheckPhaseHook,
  guiSupport,
  mpiSupport,
  isILP64 ? false,
  testers,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "salome-medcoupling";
  version = "9.14.0";

  src = fetchFromGitHub {
    owner = "SalomePlatform";
    repo = "MEDCoupling";
    tag = "V${lib.concatStringsSep "_" (lib.versions.splitVersion finalAttrs.version)}";
    hash = "sha256-YyCfceN6WKR5KxOS1qWMNRhL1osQkryGqa0zkWqxPv8=";
  };

  nativeBuildInputs = [
    cmake
    swig
    configuration
  ];

  buildInputs = [
    boost
    mpi
    metis
    scotch
    medfile
    hdf5
    libtirpc
    libxml2
  ];

  propagatedBuildInputs = [
    python3Packages.scipy
  ] ++ lib.optional mpiSupport (python3Packages.mpi4py.override { inherit mpi; });

  cmakeFlags = [
    (lib.cmakeBool "SALOME_USE_MPI" mpiSupport)
    (lib.cmakeBool "MEDCOUPLING_BUILD_TESTS" finalAttrs.finalPackage.doCheck)
    (lib.cmakeBool "MEDCOUPLING_BUILD_DOC" false)
    # (lib.cmakeBool "MEDCOUPLING_MICROMED" true)
    (lib.cmakeBool "MEDCOUPLING_USE_MPI" mpiSupport)
    (lib.cmakeBool "MEDCOUPLING_PARTITIONER_METIS" true)
    (lib.cmakeBool "MEDCOUPLING_PARTITIONER_PARMETIS" false)
    (lib.cmakeBool "MEDCOUPLING_PARTITIONER_SCOTCH" (!mpiSupport))
    (lib.cmakeBool "MEDCOUPLING_PARTITIONER_PTSCOTCH" mpiSupport)
    (lib.cmakeBool "MEDCOUPLING_USE_64BIT_IDS" isILP64)
    (lib.cmakeFeature "MEDCOUPLING_INSTALL_CMAKE_LOCAL" "lib/cmake/medcoupling")
    (lib.cmakeFeature "LIBXML2_LIBRARY" "xml2")
  ];

  doCheck = false;

  preCheck = ''
    export MEDCOUPLING_ROOT_DIR=$PWD/..
  '';

  nativeCheckInputs = [
    pkg-config
    cppunit
    # ctestCheckHook
    mpiCheckPhaseHook
  ];

  # disabledTests = [
  #   # timed out tests
  #   "PyPara_InterpKernelDEC_Proc4"
  #   "PyPara_InterpKernelDEC_Proc5"
  #   "PyPara_OverlapDEC_Proc4"
  #   # require med
  #   "PyPara_StructuredCoincidentDEC_Proc4"
  #   # name 'DataArrayDouble_Aggregate' is not defined
  #   "MEDCouplingBasicsTest2"
  #   # assertion failed
  #   "MEDCouplingBasicsTest7"
  # ];

  setupHook = ./setup-hook.sh;

  passthru.tests = {
    cmake-config = testers.hasCmakeConfigModules {
      moduleNames = [ "MEDCoupling" ];
      package = finalAttrs.finalPackage;
    };
  };

  meta = {
    description = "MEDCoupling module of the SALOME platform";
    homepage = "https://www.salome-platform.org";
    downloadPage = "https://github.com/SalomePlatform/MEDCoupling ";
    license = with lib.licenses; [ lgpl21Plus ];
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ qbisi ];
  };
})
