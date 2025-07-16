{
  nixConfig = {
    extra-substituters = [
      "https://attic.csrc.eu.org/nur-fem"
    ];
    extra-trusted-public-keys = [
      "nur-fem:YgFZCrwgfs9krm3KuUbDpsJ/Q7cIF6IcRH3H06b4uD0="
    ];
  };

  inputs = {
    nur-fem.url = "github:qbisi/nur-fem";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      perSystem =
        {
          config,
          pkgs,
          lib,
          system,
          self',
          inputs',
          ...
        }:
        {
          _module.args = {
            pkgs = import inputs.nur-fem {
              inherit system;
              overlays = [
                (final: prev: {
                  petsc = prev.petsc.override {
                    # withFullDeps = true;
                    # scalarType = "complex";
                    # debug = false;
                  };
                })
              ];
              config = {
                allowUnfree = true;
              };
            };
          };

          devShells.default =
            let
              python-env = pkgs.jupyter.withPackages (
                ps: with ps; [
                  firedrake
                  scipy
                  matplotlib
                  notebook
                  ipykernel
                ]
              );
            in
            pkgs.mkShell {
              packages = [
                python-env
              ];

              env.OMP_NUM_THREADS = 1;

              shellHook = ''
                rm .venv -rf
                ln -s ${python-env} .venv
                export VIRTUAL_ENV=$HOME
                export FIREDRAKE_TSFC_KERNEL_CACHE_DIR=$VIRTUAL_ENV/.cache/tsfc
                export PYOP2_CACHE_DIR=$VIRTUAL_ENV/.cache/pyop2
              '';
            };
        };
    };
}
