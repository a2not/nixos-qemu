{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";

    nixpkgs.url = "github:NixOS/nixpkgs/23.11";
  };

  outputs = {
    flake-utils,
    nixpkgs,
    ...
  } @ inputs: let
    systemSettings = {
      hostname = "nixos";
      timezone = "Asia/Tokyo";
      locale = "en_US.UTF-8";
      stateVersion = "23.11";
    };

    userSettings = {
      username = "a2not";
      name = "a2not";
      email = "a2not.dev@gmail.com";
    };
  in
    flake-utils.lib.eachDefaultSystem (
      hostSystem: let
        pkgs = nixpkgs.legacyPackages."${hostSystem}";

        machine = nixpkgs.lib.nixosSystem {
          system = builtins.replaceStrings ["darwin"] ["linux"] hostSystem;

          modules = [
            ./nixos/vm.nix
            ./nixos/configuration.nix
          ];

          specialArgs = {
            inherit inputs;
            inherit hostSystem;
            inherit nixpkgs;
            inherit systemSettings;
            inherit userSettings;
          };
        };

        program = pkgs.writeShellScript "run-vm.sh" ''
          export NIX_DISK_IMAGE=$(mktemp -u -t nixos.qcow2)

          trap "rm -f $NIX_DISK_IMAGE" EXIT

          ${machine.config.system.build.vm}/bin/run-nixos-vm
        '';
      in {
        packages = {inherit machine;};

        apps.default = {
          type = "app";

          program = "${program}";
        };
      }
    );
}
