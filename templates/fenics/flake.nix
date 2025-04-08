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
          ...
        }:
        {
          _module.args = {
            pkgs = import inputs.nixpkgs {
              inherit system;
              overlays = [
                inputs.nur-fem.overlays.default
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
                  fenics-dolfinx
                  scipy
                  matplotlib
                  ipykernel
                  ipympl
                  vtk
                  pyvista
                  pyvistaqt
                  # add extra python module here
                ]
              );
            in
            pkgs.mkShell {
              packages = [
                pkgs.hello
              ];

              env.OMP_NUM_THREADS = 1;

              shellHook = ''
                rm .venv -rf
                ln -s ${python-env} .venv
              '';
            };
        };
    };
}
