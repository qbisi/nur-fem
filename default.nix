{
  system ? builtins.currentSystem,
}:
let
  flake = import ./flake-compat.nix {};
in
import flake.inputs.nixpkgs {
  inherit system;
  overlays = [ flake.overlays.default ];
}
