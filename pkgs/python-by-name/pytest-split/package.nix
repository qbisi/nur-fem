{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  poetry-core,
  pytest,
  pytestCheckHook,
  pytest-cov,
}:

buildPythonPackage rec {
  version = "0.10.0";
  pname = "pytest-split";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "jerry-git";
    repo = "pytest-split";
    tag = version;
    hash = "sha256-1HXs5tmLbTXTcvGEPGkO8eeV3UhXNrmgax5AIfj8gvA=";
  };

  postPatch = ''
    substituteInPlace tests/test_plugin.py --replace-fail \
       "'duration_based_chunks', 'least_duration'" \
       "duration_based_chunks, least_duration"
  '';

  build-system = [
    poetry-core
  ];

  dependencies = [
    pytest
  ];

  # pythonImportsCheck = [ "pyvistaqt" ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov
  ];

  meta = {
    homepage = "https://jerry-git.github.io/pytest-split";
    downloadPage = "https://github.com/jerry-git/pytest-split";
    description = "Pytest plugin which splits the test suite to equally sized sub suites based on test execution time";
    changelog = "https://github.com/jerry-git/pytest-split/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ qbisi ];
  };
}
