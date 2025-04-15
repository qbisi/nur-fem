Nix direnv for many fem software development

Supported fem software

- [x] firedrake
- [x] ngsolve
- [x] fenics
- [x] mfem
- [ ] asfem
- [ ] freefem


# How to start
## install nix(for none nixos user)
single user mode is recommended
```
sh <(curl -L https://nixos.org/nix/install) --no-daemon
```

## enable nix experimental feature
```
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf
```

## install direnv and nix-direnv
```
nix profile install nixpkgs#{nix-direnv,direnv}
echo 'eval "$(~/.nix-profile/bin/direnv hook bash)""' >> ~/.bashrc
mkdir -p ~/.config/direnv
echo "source $HOME/.nix-profile/share/nix-direnv/direnvrc" > ~/.config/direnv/direnvrc
```

## init project from template
```
nix flake new -t github:qbisi/nur-fem#firedrake fem-demo
cd fem-demo
direnv allow .
```

## for graphic program
```
add nixGLHook in your shell packages
```

# How to uninstall
```
rm -rf ~/.nix-*
rm /nix -rf
```
