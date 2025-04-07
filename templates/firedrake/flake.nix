{
  nixConfig = {
    substituters = [
      "https://attic.csrc.eu.org/nur-fem"
    ];
    trusted-public-keys = [
      "nur-fem:YgFZCrwgfs9krm3KuUbDpsJ/Q7cIF6IcRH3H06b4uD0="
    ];
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  inputs = {
    nur-fem.url = "github:qbisi/nur-fem";
    nixpkgs.follows = "nur-fem/nixpkgs";
  };

  outputs =
    { nur-fem, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          nur-fem.overlays.default
        ];
        config = {
          allowUnfree = true;
        };
      };
      python-env = pkgs.jupyter.withPackages (
        ps: with ps; [
          firedrake
          matplotlib
          ipykernel
          ipympl
          vtk
        ]
      );
    in
    {
      devShells."${system}".default = pkgs.mkShell {
        packages = [
          python-env
        ];

        env.OMP_NUM_THREADS = 1;

        shellHook = ''
          rm .venv -rf
          ln -s ${python-env} .venv
          export VIRTUAL_ENV=$HOME
        '';
      };
    };
}
