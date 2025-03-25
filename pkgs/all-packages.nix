{
  systems = [
    "x86_64-linux"
    "aarch64-linux"
    # "aarch64-darwin"
  ];

  imports = [ ./python-packages.nix ];

  perSystem =
    {
      config,
      pkgs,
      lib,
      self',
      ...
    }:
    {
      legacyPackages = lib.makeScope pkgs.newScope (
        self:
        lib.packagesFromDirectoryRecursive {
          inherit (self) callPackage;
          directory = ./by-name;
        }
        // {
          petscPackages = self.petsc.petscPackages;
          python3Packages = config.legacyPackages.python312Packages;
        }
      );
    };
}
