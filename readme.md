Nix direnv for many fem software development

Supported fem software

- [x] firedrake
- [x] ngsolve
- [x] fenics
- [ ] mfem
- [ ] asfem
- [ ] freefem


# How to start
## install nix
Follow the instruction https://nixos.org/download/.
Multi-user installation is recommended.

## enable nix experimental feature
```
echo "experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf
echo "trusted-users = $USER" | sudo tee -a /etc/nix/nix.conf
sudo systemctl restart nix-daemon
```

## install direnv and nix-direnv
```
nix profile install nixpkgs#{nix-direnv,direnv}
echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
mkdir -p ~/.config/direnv
echo "source $HOME/.nix-profile/share/nix-direnv/direnvrc" > ~/.config/direnv/direnvrc
```

## init project from template
```
nix flake new -t github:qbisi/nur-fem#firedrake fem-demo
cd fem-demo
direnv allow .
```
