{
  inputs,
  lib,
  config,
  pkgs,
  systemSettings,
  userSettings,
  ...
}: {
  imports = [
    # ./hardware-configuration.nix
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  # This will add each flake input as a registry
  # To make nix3 commands consistent with your flake
  nix.registry = (lib.mapAttrs (_: flake: {inherit flake;})) ((lib.filterAttrs (_: lib.isType "flake")) inputs);

  # This will additionally add your inputs to the system's legacy channels
  # Making legacy nix commands consistent as well, awesome!
  nix.nixPath = ["/etc/nix/path"];
  environment.etc =
    lib.mapAttrs'
    (name: value: {
      name = "nix/path/${name}";
      value.source = value.flake;
    })
    config.nix.registry;

  nix.settings = {
    experimental-features = "nix-command flakes";
    auto-optimise-store = true;
  };

  networking.hostName = systemSettings.hostname;
  # networking.networkmanager.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  time.timeZone = systemSettings.timezone;

  security = {
    sudo.wheelNeedsPassword = false;
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = false;
    };
  };

  # set default shell to zsh
  environment.shells = with pkgs; [zsh];
  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;
  # programs.zsh.enableCompletion
  environment.pathsToLink = ["/share/zsh"];

  # Add ~/.local/bin to PATH
  environment.localBinInPath = true;

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    neovim
    wget
    zsh
    git
  ];

  services.getty.autologinUser = userSettings.username;
  users.users = {
    ${userSettings.username} = {
      isNormalUser = true;
      group = "users";
      home = "/home/" + userSettings.username;
      createHome = true;
      extraGroups = ["networkmanager" "wheel"]; # TODO: docker
      shell = pkgs.zsh;
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = systemSettings.stateVersion;
}
