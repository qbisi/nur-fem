{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  numpy,
  pytestCheckHook,
}:

buildPythonPackage rec {
  version = "1.0.4";
  pname = "checkpoint-schedules";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "firedrakeproject";
    repo = "checkpoint_schedules";
    tag = "v${version}";
    sha256 = "sha256-3bn/KxxtRLRtOHFeULQdnndonpuhuYLL8/y/zoAurzY=";
  };

  build-system = [ setuptools ];

  dependencies = [
    numpy
  ];

  pythonImportsCheck = [
    "checkpoint_schedules"
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  meta = {
    homepage = "https://github.com/firedrakeproject/checkpoint_schedules";
    description = "Provides schedules for step-based incremental checkpointing of the adjoints to computer models";
    changelog = "https://github.com/firedrakeproject/checkpoint_schedules/releases/tag/${src.tag}";
    license = lib.licenses.lgpl3;
    maintainers = with lib.maintainers; [ qbisi ];
  };
}
