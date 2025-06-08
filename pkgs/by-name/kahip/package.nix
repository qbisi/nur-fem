{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch2,
  cmake,
  mpi,
  metis,
  python3Packages,
  pythonSupport ? false,
  isILP64 ? false,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "kahip";
  version = "3.19";

  src = fetchFromGitHub {
    owner = "KaHIP";
    repo = "KaHIP";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PySbhryPSqr2fzInYPaNQzy4MBuinJ4XJ38zxAa0lCE=";
  };

  patches = [
    (fetchpatch2 {
      url = "https://github.com/KaHIP/KaHIP/pull/158/commits/0e12e01657260879fbed52aa131393cf5eb2fb7c.patch?full_index=1";
      hash = "sha256-JI29l/BnNUYaKKcKx6YcNJ3+nQjxEprsB5igvXrEHpw=";
    })
  ];

  nativeBuildInputs =
    [ cmake ]
    ++ lib.optionals pythonSupport [
      python3Packages.python
      python3Packages.pybind11
      python3Packages.pythonImportsCheckHook
    ];

  buildInputs = [
    mpi
    metis
  ];

  cmakeFlags = [
    (lib.cmakeBool "64BITMODE" isILP64)
    (lib.cmakeBool "BUILD_SHARED_LIBS" (!stdenv.hostPlatform.isStatic))
    (lib.cmakeBool "BUILDPYTHONMODULE" pythonSupport)
    (lib.cmakeFeature "CMAKE_INSTALL_PYTHONDIR" python3Packages.python.sitePackages)
  ];

  pythonImportsCheck = [ "kahip" ];

  meta = {
    homepage = "https://kahip.github.io/";
    downloadPage = "https://github.com/KaHIP/KaHIP/";
    changelog = "https://github.com/KaHIP/KaHIP/releases/tag/v${finalAttrs.version}";
    description = "Karlsruhe HIGH Quality Partitioning";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ qbisi ];
  };
})
