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
      {
        lib,
        self,
        withSystem,
        ...
      }@top:
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

            hydraJobs = {
              packages = lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux (
                lib.packagesFromDirectoryRecursive {
                  inherit (self'.legacyPackages) callPackage;
                  directory = ./pkgs/by-name;
                }
              );
              python312Packages = lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux (
                lib.packagesFromDirectoryRecursive {
                  inherit (self'.legacyPackages.python312Packages) callPackage;
                  directory = ./pkgs/python-by-name;
                }
              );
              tests = lib.mapAttrs (_: v: lib.mapAttrs (_: package: { tests = package.tests or { }; }) v) (
                builtins.removeAttrs config.hydraJobs [ "tests" ]
              );
            };
          };

        transposition.hydraJobs.adHoc = true;

        flake = {
          templates = {
            firedrake = {
              path = ./templates/firedrake;
              description = "firdrake template";
            };
          };

          nixosModules.default = {
            nixpkgs.overlays = [
              self.overlays.pkgs-fem
            ];
          };

          overlays.pkgs-fem = final: prev: {
            pkgs-fem = self."${prev.stdenv.hostPlatform.system}".legacyPackages;
          };
        };
      }
    );
}
