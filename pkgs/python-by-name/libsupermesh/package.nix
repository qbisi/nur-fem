{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  gfortran,
  mpi,
  cmake,
  ninja,
  libspatialindex,
  scikit-build-core,
  rtree,
}:

buildPythonPackage rec {
  pname = "libsupermesh";
  version = "2025.3.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "firedrakeproject";
    repo = "libsupermesh";
    tag = "v${version}";
    hash = "sha256-RKBi89bUhkbRATaSB8629D+/NeYE3YNDIMEGzSK8z04=";
  };

  build-system = [
    gfortran
    cmake
    ninja
    mpi
    scikit-build-core
  ];

  dontUseCmakeConfigure = true;

  buildInputs = [
    libspatialindex
    gfortran.cc.lib
  ];

  dependencies = [
    rtree
  ];

  # backend scikit-build-core does not run cmake tests
  doCheck = false;

  meta = {
    homepage = "https://github.com/firedrakeproject/libsupermesh";
    description = "Parallel supermeshing library";
    changelog = "https://github.com/firedrakeproject/libsupermesh/releases/tag/${src.tag}";
    license = lib.licenses.lgpl2Plus;
    maintainers = with lib.maintainers; [ qbisi ];
  };
}
