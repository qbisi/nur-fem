{
  lib,
  stdenv,
  buildPythonPackage,
  fetchFromGitHub,
  flit-core,
  pytest,
  pyvista,
  pytestCheckHook,
  headlessDisplayHook,
}:

buildPythonPackage rec {
  pname = "pytest-pyvista";
  version = "0.1.9";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "pyvista";
    repo = "pytest-pyvista";
    tag = "v${version}";
    hash = "sha256-E+1PV0tBKzwqERytsTc8YA2IiRezmUSK3UXSEzLSpxg=";
  };

  build-system = [ flit-core ];

  dependencies = [
    pytest
    pyvista
  ];

  doCheck = stdenv.hostPlatform.isLinux;

  nativeCheckInputs = [
    pytestCheckHook
    headlessDisplayHook
  ];

  # capable of doing onscreen/offscreen plot
  env.ALLOW_PLOTTING = "true";

  pythonImportsCheck = [ "pytest_pyvista" ];

  meta = {
    description = "Plugin to test PyVista plot outputs";
    homepage = "https://github.com/pyvista/pytest-pyvista";
    changelog = "https://github.com/pyvista/pytest-pyvista/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ qbisi ];
  };
}
