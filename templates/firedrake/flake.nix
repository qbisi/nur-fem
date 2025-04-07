{
  nixConfig = {
    substituters = [
      "https://cache.nixos.org/"
      "https://cache.csrc.eu.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "cache.csrc.eu.org:n1NPgbHzbDgdaaaUrrsX0B4JedprWWMudJ4vyN7mOkU="
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
