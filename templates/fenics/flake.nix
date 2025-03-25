{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    nur-fem = {
      url = "github:qbisi/nur-fem";
      inputs.nixpkgs.follows = "nixpkgs";
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
          pkgs,
          pkgs-fem,
          system,
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

          devShells = {
            default =
              let
                python-env = pkgs.jupyter.withPackages (
                  ps: with ps; [
                    fenics-dolfinx
                    matplotlib
                    ipykernel
                    ipympl
                  ]
                );
              in
              pkgs.mkShell {
                packages = [
                  python-env
                ];

                OMP_NUM_THREADS = 1;

                shellHook = ''
                  rm .venv -rf
                  ln -s ${python-env} .venv
                '';
              };
          };

          formatter = pkgs.nixfmt-rfc-style;
        };
    };
}
