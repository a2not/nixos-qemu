# NixOS VM with QEMU on darwin host machine

goal is to use this as my personal, disposable development environment.

## setup

Use [darwin.linux-builder](https://nixos.org/manual/nixpkgs/stable/#sec-darwin-builder) to enable building NixOS VM on darwin machine.

### 1. for only once for a host machine

Need to replace some variables accordingly.

- Replace ${ARCH} with either aarch64 or x86_64 to match your host machine
- Replace ${MAX_JOBS} with the maximum number of builds (pick 4 if you're not sure)

```bash
sudo echo "extra-trusted-users = $(whoami)" >> /etc/nix/nix.conf

mkdir -p ~/.config/nix/
touch ~/.config/nix/nix.conf
cat > ~/.config/nix/nix.conf << EOL
builders = ssh-ng://builder@linux-builder ${ARCH}-linux /etc/nix/builder_ed25519 ${MAX_JOBS} - - - c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUpCV2N4Yi9CbGFxdDFhdU90RStGOFFVV3JVb3RpQzVxQkorVXVFV2RWQ2Igcm9vdEBuaXhvcwo=
builders-use-substitutes = true
EOL

mkdir -p /etc/ssh/ssh_config.d/
touch /etc/ssh/ssh_config.d/100-linux-builder.conf
cat > /etc/ssh/ssh_config.d/100-linux-builder.conf << EOL
Host linux-builder
  Hostname localhost
  HostKeyAlias linux-builder
  Port 31022
EOL

sudo launchctl kickstart -k system/org.nixos.nix-daemon
```

### 2. each time building VM

Keep this remote builder running in the background.

```bash
nix run nixpkgs#darwin.linux-builder
```

## build VM

Simply run `nix run`.

```bash
nix run
```
