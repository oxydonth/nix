# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  unstable = import <nixos-unstable> { config.allowUnfree = true; };
in
{
  nix.daemonIONiceLevel = 5;
  nix.daemonNiceLevel = 5;
  nix.gc = {
    automatic = true;
    dates = "13:00";
    options = "--delete-older-than 30d";
  };

  nixpkgs.config.allowUnfree = true;

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./host.nix
    ];

  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;

  hardware.ksm.enable = true;
  hardware.u2f.enable = true;


  console.font = "Lat2-Terminus16";
  console.keyMap = "us";
  i18n.defaultLocale = "en_US.UTF-8";

  time.timeZone = "Europe/Berlin";



  fonts = {
    enableDefaultFonts = true;
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fontconfig = {
      enable = true;
      allowBitmaps = true;
    };
    fonts = with pkgs; [
      terminus_font
      terminus_font_ttf
      corefonts
      inconsolata
      ubuntu_font_family
      unifont
      twemoji-color-font
    ];
  };

  hardware.pulseaudio = {
    enable = true;
    support32Bit = true;
    package = pkgs.pulseaudioFull;
  };

  services = {
    flatpak.enable = true;
    avahi = {
      enable = true;
      nssmdns = true;
    };
    openssh.enable = true;
    openssh.forwardX11 = true;
    udisks2.enable = true;
    printing.enable = true;
    xserver = 
    let xkbVariant = "altgr-intl"; # no dead keys
        xkbOptions = "eurosign:e,compose:menu,lv3:caps_switch";
    in {
      inherit xkbVariant xkbOptions;

      enable = true;
      layout = "us";
      exportConfiguration = true;

      displayManager.gdm = {
        enable = true;
        nvidiaWayland = false;
        autoLogin = {
          enable = false;
          user = "bara";
        };
      };
      desktopManager.gnome3 = {
        enable = true;
        extraGSettingsOverrides = ''
          [org.gnome.desktop.input-sources]
          sources=[('xkb', '${xkbVariant}')]
          xkb-options=['${xkbOptions}']
        '';
      };
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.bara = {
    isNormalUser = true;
    uid = 1000;
    group = "bara";
    extraGroups = [ "dialout" "avahi" "users" "video" "wheel" "adm" "audio" "docker" "input" "vboxusers" "adbusers" "libvirtd" ];
    createHome = true;
    shell = pkgs.zsh;
  };
  users.extraGroups.bara.gid = 1000;


  environment.systemPackages = with pkgs; [
    aspell
    aspellDicts.de
    aspellDicts.en
    autojump
    avahi
    cifs-utils
    curl
    docker
    dosfstools
    espeak
    evince
    firefox
    gimp
    gitAndTools.gitFull
    # broken again
    #gnomeExtensions.system-monitor
    gnumake
    google-chrome
    google-cloud-sdk
    hdparm
    htop
    imagemagick
    iotop
    lm_sensors
    meld
    mtools
    ntfs3g
    nextcloud-client
    pamixer
    pass
    pavucontrol
    python
    renameutils
    seafile-client
    slack
    source-code-pro
    speechd
    sshfsFuse
    teamviewer
    vlc
    wget
    zsh
    samba
    (vscode-with-extensions.override {
        vscode = vscodium;
        # When the extension is already available in the default extensions set.
        vscodeExtensions = with vscode-extensions; [
          bbenoist.Nix
          ms-kubernetes-tools.vscode-kubernetes-tools
          redhat.vscode-yaml
          vscodevim.vim

        ]
        # Concise version from the vscode market place when not available in the default set.
        ++ vscode-utils.extensionsFromVscodeMarketplace [
          {
            name = "codestream";
            publisher = "CodeStream";
            version = "6.0.1";
            sha256 = "0q6k3g2brmk5nf09z846d4whgv99rjmr928qzagqnv0fv1n9fyjf";
          }
        ];
      })

    (nmap.override {
        graphicalSupport = true;
    })
    (vim_configurable.customize {
      name = "vim";
      vimrcConfig.customRC = ''
      syntax enable
      set smartindent
      set smartcase
      set cursorline
      set visualbell
      set hlsearch
      set incsearch
      set ruler
      set backspace=indent,eol,start
      '';
      vimrcConfig.vam.knownPlugins = pkgs.vimPlugins;
      vimrcConfig.vam.pluginDictionaries = [
        { names = [
          "vim-nix"
        ];}
      ];
    })
    # use version with seccomp fix
    (proot.overrideAttrs (oldAttrs: {
      src = fetchFromGitHub {
        repo = "proot";
        owner = "jorge-lip";
        rev = "25e8461cbe56a3f035df145d9d762b65aa3eedb7";
        sha256 = "1y4rlx0pzdg4xsjzrw0n5m6nwfmiiz87wq9vrm6cy8r89zambs7i";
      };
      version = "5.1.0.20171102";
    }))
  ];

  services.gvfs.enable = true;
  services.fwupd.enable = true;
  services.gnome3 = {
    chrome-gnome-shell.enable = true;
    gnome-keyring.enable = true;
    gnome-online-accounts.enable = true;
    gnome-online-miners.enable = true;
    gnome-user-share.enable = true;
    tracker-miners.enable = true;
    tracker.enable = true;
    sushi.enable = true;
  };
  services.earlyoom.enable = true;

  programs.seahorse.enable = true;
  programs.gnome-terminal.enable = true;
  programs.gnome-documents.enable = true;
  programs.gnome-disks.enable = true;

  #services.teamviewer.enable = true;

  # ram verdoppler
  zramSwap.enable = false;

  programs.adb.enable = true;
  programs.bash.enableCompletion = true;
  programs.zsh.enable = true;

  #environment.etc."qemu/bridge.conf".text = ''
  #  allow bridge0
  #'';
  boot.kernelParams = [ "bluetooth.disable_ertm=1" ];

  # raise limit to avoid steamplay problems
  systemd.extraConfig = "DefaultLimitNOFILE=1048576";

  programs.autojump.enable = true;

  hardware.bluetooth = {
    enable = true;
    package = pkgs.bluezFull;
  };
}
