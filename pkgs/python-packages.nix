{
  systems = [
    "x86_64-linux"
    "aarch64-linux"
    # "aarch64-darwin"
  ];
  perSystem =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      legacyPackages =
        let
          pythonOverrides =
            self: prev:
            lib.packagesFromDirectoryRecursive {
              inherit (self) callPackage;
              directory = ./python-by-name;
            }
            // {
              pkgs = prev.pkgs // config.legacyPackages;

              netgen-mesher = prev.toPythonModule (self.pkgs.netgen.override { python3Packages = self; });

              ngsolve = prev.toPythonModule (self.pkgs.ngsolve.override { python3Packages = self; });
            };
        in
        {
          python312 = pkgs.python312.override (old: {
            packageOverrides = lib.composeExtensions (old.packageOverrides or (_: _: { })) pythonOverrides;
          });

          python313 = pkgs.python312.override (old: {
            packageOverrides = lib.composeExtensions (old.packageOverrides or (_: _: { })) pythonOverrides;
          });

          python312Packages = lib.recurseIntoAttrs config.legacyPackages.python312.pkgs;

          python313Packages = lib.recurseIntoAttrs config.legacyPackages.python313.pkgs;
        };
    };
}
