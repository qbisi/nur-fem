{
  system ? args.system or builtins.currentSystem,
  overlays ? [ ],
  config ? { },
}@args:
let
  flake = import ./flake-compat.nix { inherit system; };
in
import flake.inputs.nixpkgs {
  inherit system config;
  overlays = overlays ++ [ flake.overlays.default ];
}
