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
    nixpkgs.follows = "nur-fem/nixpkgs";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
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
            pkgs = import inputs.nixpkgs {
              inherit system;
              overlays = [
                inputs.nur-fem.overlays.default
                (final: prev: {
                  petsc = prev.petsc.override {
                    # custom petsc configuration
                    # mpi = prev.mpich;
                    # blasProvider = prev.mkl;
                    # scalarType = "complex";
                    # withFullDeps = true;
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
                  matplotlib
                  ipykernel
                  ipympl
                  vtk

                  # add extra python module here
                  # available python module can be searched on https://search.nixos.org/
                  pyvisata
                  pyvistaqt
                ]
              );
            in
            pkgs.mkShell {
              packages = [
                python-env

                # add extra pkgs here
                pkgs.nixGLHook   # required for running grphic program via ssh x11 forwarding
                # pkgs.paraview
              ];

              env.OMP_NUM_THREADS = 1;

              shellHook = ''
                rm .venv -rf
                ln -s ${python-env} .venv
                export VIRTUAL_ENV=$HOME
              '';
            };
        };
    };
}
