{
  description = "NixOS flake for managing system";


  outputs = inputs@{ self, ... }:
    let
      # -=-=-=- SYSTEM SETTINGS -=-=-=- #
      systemSettings = {
        system = "x86_64-linux"; # system arch
        hostname = "nixos"; # hostname
        profile = "work"; # select a profile from the profiles directory
        timezone = "Europe/Brussels"; # select timezone
        locale = "en_US.UTF-8"; # select locale
        bootMode = "uefi"; # uefi or bios
        bootMountPath = "/boot"; # mount path for efi boot partition (only used for uefi boot mode)
        grubDevice = ""; # device identifier for grub (only used for legacy (bios) boot mode)
        gpuType = "nvidia"; # amd, intel or nvidia
      };

      # -=-=-=- USER SETTINGS -=-=-=- #
      userSettings = rec {
        username = "kyan"; # username
      };

      lib = inputs.nixpkgs.lib;
      pkgs = inputs.nixpkgs.legacyPackages.${systemSettings.system};

    in {
      nixosConfigurations = {
        ${systemSettings.hostname} = lib.nixosSystem {
          system = systemSettings.system;
          modules = [ (./. + "/profiles" + ("/" + systemSettings.profile) + "/configuration.nix") ];
          specialArgs = {
            # pass config variables from above
            inherit systemSettings;
            inherit userSettings;
          };
        };
      };

      homeConfigurations = {
        kyan = inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ (./. + "/profiles" + ("/" + systemSettings.profile) + "/home.nix") ]; # load home.nix from selected profile
          extraSpecialArgs = {
            # pass config variables from above
            inherit systemSettings;
            inherit userSettings;
          };
        };
      };
    };
  
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs"; # Ensures compatibility between nixpkgs and home-manager version
  };
}    
