Nix direnv for many fem software development

Supported fem software

- [x] firedrake
- [x] ngsolve
- [x] fenics
- [x] mfem
- [ ] asfem
- [ ] freefem


# How to start
## install nix (for none nixos user)
### single user mode (recommended)
```
sh <(curl -L https://nixos.org/nix/install) --no-daemon
```
### docker
```
docker run -it ghcr.io/nixos/nix
```

## enable nix experimental feature
```
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf
source ~/.nix-profile/etc/profile.d/nix.sh
```

## install direnv and nix-direnv
### bash
```
nix profile install nixpkgs#{nix-direnv,direnv}

cat <<EOF >> ~/.bashrc
eval "\$(~/.nix-profile/bin/direnv hook bash)"
source ~/.nix-profile/share/nix-direnv/direnvrc
EOF

source ~/.bashrc
```
### zsh
```
nix profile install nixpkgs#{nix-direnv,direnv}

cat <<EOF >> ~/.zshrc
eval "\$(~/.nix-profile/bin/direnv hook zsh)"
source ~/.nix-profile/share/nix-direnv/direnvrc
EOF

source ~/.zshrc
```
### home-manager
```
programs.direnv = {
  enable = true;
  nix-direnv.enable = true;
};
```

## init project from template
```
nix flake new -t github:qbisi/nur-fem#firedrake fem-demo
cd fem-demo
direnv allow .
mpiexec -np 1 python poission.py
```

# How to uninstall
```
rm -rf ~/.nix-*
rm /nix -rf
```
