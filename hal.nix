{ config, pkgs, ... }:
let linuxPackages = pkgs.linuxPackages_5_4;
in
{
  nixpkgs.overlays = [
    (import ./overlays/asus-wmi.nix)
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = null;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = linuxPackages;
  boot.extraModulePackages = with linuxPackages; [ asus-wmi-sensors ];
  boot.extraModprobeConfig = ''
    options bluetooth disable_ertm=1
  '';


  hardware.bluetooth.enable = true;
  hardware.steam-hardware.enable = true;

  boot.initrd.luks.devices."crypt-ssd".allowDiscards = true;
  fileSystems."/".options= ["defaults" "discard" ];

  swapDevices = [
    {
      device = "/dev/disk/by-partlabel/cryptswap";
      randomEncryption.enable = true;
    }
  ];
  systemd.units."dev-sdc2.swap".enable = false;
  systemd.generators.systemd-gpt-auto-generator = "/dev/null";

  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = "ondemand";


  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
    storageDriver = "overlay2";
  };

  services.printing = {
    enable = true;
    drivers = [ pkgs.hplip ];
  };

  services.logind.extraConfig = ''
  HandlePowerKey=suspend
  '';

  networking.hostName = "hal";
  networking.firewall.enable = false;

  services.xserver.videoDrivers = [ "nvidiaBeta" ];
  services.xserver.screenSection = ''
    Option         "metamodes" "DP-2: nvidia-auto-select +0+0 {AllowGSYNCCompatible=On}, HDMI-0: nvidia-auto-select +3440+0"
  '';
  system.stateVersion = "18.09";

  services.wakeonlan.interfaces = [
    { interface = "enp4s0"; method = "magicpacket"; }
  ];

  boot.kernelParams = [
    "nopti"
    "bluetooth.disable_ertm=1"
    "spectre_v2=off"
    "nouveau.modeset=0"
  ];
  boot.kernelModules = [ "nct6775" ];
}
