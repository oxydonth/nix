{ config, pkgs, ... }:

let
  unstable = (import <nixos-unstable> {
  config.allowUnfree = true;
}).pkgs;
in
 {

  nixpkgs.config = {
    allowUnfree = true;
  };

  environment.systemPackages = with pkgs; [
    cifs-utils
    unstable.sway
    unstable.jetbrains.rider
    xsettingsd
    lightlocker
    source-code-pro
    owncloudclient
    pass
    rofi
    emacs
    teamviewer
    unstable.google-chrome
    gimp
    imagemagick
    autojump
    renameutils
    bc
    seafile-client
    meld
    vlc
    mtools
    dosfstools
    ntfs3g
    dunst
    espeak
    avahi
    curl
    dmenu
    docker
    darktable
    evince
    firefox
    gcc
    gitAndTools.gitFull
    gnumake
    hdparm
    htop
    lm_sensors
    i3
    i3lock
    i3status
    iotop
    (nmap.override {
        graphicalSupport = true;
    })
    speechd
    mumble
    aspell
    aspellDicts.de
    aspellDicts.en
    gpicview
    networkmanagerapplet
    numlockx
    pamixer
    pavucontrol
    pcmanfm
    python
    roxterm
    slack
    sshfsFuse
    steam
    synergy
    wget
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
    wine
    xorg.xmodmap
    xss-lock
    zsh
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
    (smartgithg.overrideAttrs (oldAttrs: rec {
      version = "17_1_6";
      src = fetchurl {
        url = "https://www.syntevo.com/downloads/smartgit/archive/smartgit-linux-${version}.tar.gz";
        sha256 = "14p2yzky1nszqd4yg258065h8y6cca3xgq90xrqy0w57isjxlak2";
      };
    }))
    gtk_engines
    xpra
  ];

}
