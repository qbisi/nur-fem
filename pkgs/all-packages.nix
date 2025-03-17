{
  systems = [
    "x86_64-linux"
    "aarch64-linux"
    "x86_64-darwin"
    "aarch64-darwin"
  ];
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
      );
    };
}
