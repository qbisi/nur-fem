{
  lib,
  python,
  buildPythonPackage,
  fetchFromGitHub,
  fetchNpmDeps,
  npmHooks,
  nodejs,
  setuptools,
  trame-common,
}:

buildPythonPackage rec {
  pname = "trame-client";
  version = "3.9.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "kitware";
    repo = "trame-client";
    tag = "v${version}";
    hash = "sha256-8APnUbuogO2IYHnFAhbfVE3HVc3yz4FvjAsHxWKeHsc=";
  };

  nativeBuildInputs = [ nodejs ];

  env.npmDeps_vue2_app = fetchNpmDeps {
    name = "npm-deps-vue2-app";
    src = "${src}/vue2-app";
    hash = "sha256-qEsybpSBElUzmqCLui3DVVfBtfiLscV+SULdSGlNwck=";
  };

  env.npmDeps_vue3_app = fetchNpmDeps {
    name = "npm-deps-vue3-app";
    src = "${src}/vue3-app";
    hash = "sha256-/4GxyD5drp65ElpYSgIRDrGC1z320zGkSHnvurvi2Po=";
  };

  postPatch = ''
    sed -i '/^\[tool\.setuptools\.packages\.find\]/a include = ["trame*"]' pyproject.toml
    find trame -type f -name '__init__.py' -delete

    # Tricky way to run npmConfigHook multiple times
    (
      local postPatchHooks=() # written to by npmConfigHook
      source ${npmHooks.npmConfigHook}/nix-support/setup-hook
      npmRoot=vue2-app    npmDeps=$npmDeps_vue2_app     npmConfigHook
      npmRoot=vue3-app    npmDeps=$npmDeps_vue3_app     npmConfigHook
    )
  '';

  preBuild = ''
    echo entering vue2-app ...
    (
      cd vue2-app 
      npm run build
    )

    echo entering vue3-app ...
    (
      cd vue3-app
      npm run build
    )
  '';

  build-system = [ setuptools ];

  dependencies = [ trame-common ];

  pythonImportsCheck = [ "trame_client" ];

  doCheck = false;

  meta = {
    description = "Internal client of trame";
    homepage = "https://github.com/Kitware/trame-client";
    changelog = "https://github.com/Kitware/trame-client/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ qbisi ];
  };
}
