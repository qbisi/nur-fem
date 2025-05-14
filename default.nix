{
  system ? builtins.currentSystem,
  overlays ? [ ],
}:
let
  flake = import ./flake-compat.nix { };
in
import flake.inputs.nixpkgs {
  inherit system;
  overlays = overlays ++ [ flake.overlays.default ];
}
