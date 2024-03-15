{
  pkgs,
  systemSettings,
  userSettings,
  ...
}: {
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    auto-optimise-store = true;
  };

  security = {
    sudo.wheelNeedsPassword = false;
  };

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    neovim
    wget
    bash
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
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = systemSettings.stateVersion;
}
