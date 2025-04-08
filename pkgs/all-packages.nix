{
  # systems = [
  #   "x86_64-linux"
  #   "aarch64-linux"
  #   "x86_64-darwin"
  #   "aarch64-darwin"
  # ];

  # imports = [ ./python-packages.nix ];

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
          python312 = pkgs.python312.override (old: {
            packageOverrides = lib.composeExtensions (old.packageOverrides or (_: _: { })) self.pythonOverrides;
          });

          python313 = pkgs.python312.override (old: {
            packageOverrides = lib.composeExtensions (old.packageOverrides or (_: _: { })) self.pythonOverrides;
          });

          python3 = self.python312;

          python312Packages = lib.recurseIntoAttrs self.python312.pkgs;

          python313Packages = lib.recurseIntoAttrs self.python313.pkgs;

          python3Packages = self.python312Packages;

          pythonOverrides =
            final: prev:
            lib.packagesFromDirectoryRecursive {
              inherit (final) callPackage;
              directory = ./python-by-name;
            }
            // {
              pkgs = prev.pkgs // self;

              petsc4py = prev.toPythonModule (
                final.pkgs.petsc.override {
                  python3 = prev.python;
                  python3Packages = final;
                  pythonSupport = true;
                }
              );

              slepc4py = prev.toPythonModule (
                final.pkgs.slepc.override {
                  pythonSupport = true;
                  python3 = prev.python;
                  python3Packages = final;
                  petsc = final.petsc4py;
                }
              );

              netgen-mesher = prev.toPythonModule (
                final.pkgs.netgen.override {
                  python3Packages = final;
                }
              );

              ngsolve = prev.toPythonModule (
                final.pkgs.ngsolve.override {
                  python3Packages = final;
                }
              );

              adios2 = prev.toPythonModule (
                final.pkgs.adios2.override {
                  pythonSupport = true;
                  python3 = prev.python;
                  python3Packages = final;
                }
              );

              kahip = prev.toPythonModule (
                final.pkgs.kahip.override {
                  pythonSupport = true;
                  python3 = prev.python;
                  python3Packages = final;
                }
              );
            };
        }
      );
    };
}
