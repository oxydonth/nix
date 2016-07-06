{ config, pkgs, ... }:

{
  boot.loader.gummiboot.enable = true;
  boot.loader.gummiboot.timeout = null;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.extraKernelModules = [ "bcache" ];
  boot.initrd.luks.devices = [
    { name = "storage"; device = "/dev/bcache0"; }
  ];

  #environment.systemPackages = with pkgs; [
  #];

  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";
  };

    services.printing = {
      enable = true;
      drivers = [ pkgs.hplip ];
    };

  networking.hostName = "hal";
  networking.firewall.enable = false;

  services.xserver.videoDrivers = [ "nvidia" ];
  system.stateVersion = "16.03";

}
