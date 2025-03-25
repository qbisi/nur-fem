{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      { lib, self, ... }@top:
      {
        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "x86_64-darwin"
          "aarch64-darwin"
        ];

        imports = [
          inputs.flake-parts.flakeModules.easyOverlay
          ./pkgs/all-packages.nix
        ];

        perSystem =
          {
            config,
            pkgs,
            self',
            ...
          }:
          {
            formatter = pkgs.nixfmt-rfc-style;

            overlayAttrs = config.legacyPackages;

            packages = lib.packagesFromDirectoryRecursive {
              inherit (self'.legacyPackages) callPackage;
              directory = ./pkgs/by-name;
            };
          };

        flake = {
          hydraJobs = {
            inherit (self) packages;
          };

          templates = {
            firedrake = {
              path = ./templates/firedrake;
              description = "firdrake template";
            };
          };
        };
      }
    );
}
