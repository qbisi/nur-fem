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
    nixpkgs.url = "github:NixOS/nixpkgs/694814ad5ded753c4d266d60950d5687d77d58c0";
    nur-fem.url = "github:qbisi/nur-fem/stage";
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
              ];
              config = {
                allowUnfree = true;
              };
            };
          };

          devShells.default =
            let
              python-env = pkgs.python3.withPackages (
                ps: with ps; [
                  ngsolve
                ]
              );
            in
            pkgs.mkShell {
              packages = [
                python-env
                # add extra pkgs here
                pkgs.nixGLHook   # required for running grphic program via ssh x11 forwarding
              ];

              shellHook = ''
                rm .venv -rf
                ln -s ${python-env} .venv
              '';
            };
        };
    };
}
