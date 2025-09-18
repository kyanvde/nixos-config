{ pkgs, lib, systemSettings, ... }:
{
  boot.loader = {
    systemd-boot.enable = if (systemSettings.bootMode == "uefi") then true else false;
    efi = {
      canTouchEfiVariables = if (systemSettings.bootMode == "uefi") then true else false;
      efiSysMountPoint = systemSettings.bootMountPath; # does nothing if running bios rather than uefi
    };
    grub = {
      enable = if (systemSettings.bootMode == "uefi") then false else true;
      device = systemSettings.grubDevice; # does nothing if running uefi rather than bios
    };
  };
}
