{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    flake-compat.url = "github:nix-community/flake-compat";
  };

  outputs =
    { nixpkgs, self, ... }@inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } ({
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      imports = [
        ./pkgs/all-packages.nix
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
              config = {
                allowUnfree = true;
              };
            };
          };

          formatter = pkgs.nixfmt-rfc-style;

          devShells.default = pkgs.mkShell {
            packages = [
              (pkgs.python3.withPackages (_: [
                config.legacyPackages.python3Packages.vtk
              ]))
            ];
          };

          packages =
            (lib.packagesFromDirectoryRecursive {
              inherit (self'.legacyPackages) callPackage;
              directory = ./pkgs/by-name;
            })
            // (lib.mapAttrs' (n: v: lib.nameValuePair ("python3-" + n) v) (
              lib.packagesFromDirectoryRecursive {
                inherit (self'.legacyPackages.python3Packages) callPackage;
                directory = ./pkgs/python-by-name;
              }
            ));

          hydraJobs =
            let
              enable = pkgs.stdenv.hostPlatform.system != "x86_64-darwin";
              hydraCompile = lib.filterAttrsRecursive (n: v: v != null) {
                packages = lib.packagesFromDirectoryRecursive {
                  inherit (self'.legacyPackages) callPackage;
                  directory = ./pkgs/by-name;
                };
                python312Packages = lib.packagesFromDirectoryRecursive {
                  inherit (self'.legacyPackages.python3Packages) callPackage;
                  directory = ./pkgs/python-by-name;
                };
              };
              hydraTests = lib.mapAttrs (_: v: lib.mapAttrs (_: package: package.tests or { }) v) hydraCompile;
            in
            lib.optionalAttrs enable hydraCompile;
        };

      transposition.hydraJobs.adHoc = true;

      flake = {
        templates = {
          firedrake = {
            path = ./templates/firedrake;
            description = "firdrake template";
          };
          fenics = {
            path = ./templates/fenics;
            description = "fenics template";
          };
          ngsolve = {
            path = ./templates/ngsolve;
            description = "ngsolve template";
          };
        };

        nixosModules.default = {
          nixpkgs.overlays = [
            self.overlays.pkgs-fem
          ];
        };

        overlays.pkgs-fem = final: prev: {
          pkgs-fem = self.legacyPackages."${prev.stdenv.hostPlatform.system}";
        };
      };
    });
}
