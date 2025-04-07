Nix direnv for many fem software development

Supported fem software

- [x] firedrake
- [x] ngsolve
- [x] fenics
- [ ] mfem
- [ ] asfem
- [ ] freefem


# How to start
## install nix(for none nixos user)
single user mode is recommended
```
sh <(curl -L https://releases.nixos.org/nix/nix-2.26.3/install) --no-daemon
```

## enable nix experimental feature
```
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf
```

## install direnv and nix-direnv
```
nix profile install nixpkgs#{nix-direnv,direnv}
echo 'val "$(~/.nix-profile/bin/direnv hook bash)""' >> ~/.bashrc
mkdir -p ~/.config/direnv
echo "source $HOME/.nix-profile/share/nix-direnv/direnvrc" > ~/.config/direnv/direnvrc
```

## init project from template
```
nix flake new -t github:qbisi/nur-fem#firedrake fem-demo
cd fem-demo
direnv allow .
```
