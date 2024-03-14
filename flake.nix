{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";

    nixpkgs.url = "github:NixOS/nixpkgs/23.11";

    nixos-config.url = "github:a2not/nixos-config/main";
  };

  outputs = {
    flake-utils,
    nixpkgs,
    nixos-config,
    ...
  } @ inputs: let
    systemSettings = nixos-config.systemSettings;
    userSettings = nixos-config.userSettings;
  in
    flake-utils.lib.eachDefaultSystem (
      hostSystem: let
        pkgs = nixpkgs.legacyPackages."${hostSystem}";

        machine = nixpkgs.lib.nixosSystem {
          system = builtins.replaceStrings ["darwin"] ["linux"] hostSystem;

          modules = [
            ./nixos/vm.nix
            nixos-config.nixosConfigurations
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
