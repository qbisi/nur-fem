{ lib, self, ... }:
{
  flake.overlays.default =
    self: pkgs:
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
          inherit (self) callPackage;
          directory = ./by-name;
        }
        // lib.packagesFromDirectoryRecursive {
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
              python3Packages = final;
            }
          );

          vtk = prev.toPythonModule (
            final.pkgs.vtk.override {
              enablePython = true;
              python3Packages = final;
            }
          );
        };
    };

  perSystem =
    {
      config,
      pkgs,
      lib,
      self',
      ...
    }:
    {
      legacyPackages = lib.makeScope pkgs.newScope (final: self.overlays.default final pkgs);
    };
}
