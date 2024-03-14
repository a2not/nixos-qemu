{
  lib,
  nixpkgs,
  modulesPath,
  hostSystem,
  systemSettings,
  ...
}: let
  pkgs = nixpkgs.legacyPackages."${hostSystem}";
in {
  imports = ["${modulesPath}/virtualisation/qemu-vm.nix"];

  # https://github.com/utmapp/UTM/issues/2353
  networking.nameservers = lib.mkIf pkgs.stdenv.isDarwin ["8.8.8.8"];

  virtualisation = {
    host = {inherit pkgs;};
    cores = 4;
    memorySize = 8 * 1024;
    diskSize = 100 * 1024;
    graphics = false;

    # TODO: https://github.com/NixOS/nixpkgs/blob/ac2165529b9e8704d87badffa0e84c4f1842e935/nixos/modules/virtualisation/qemu-vm.nix#L397-L420
    # sharedDirectories =
  };

  system.stateVersion = systemSettings.stateVersion;
}
