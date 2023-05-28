{ config, lib, pkgs, my, ... }: 

with lib;
{
  imports = [ ./udev.nix ];
  
  time.timeZone = "Europe/London";

  bluetooth.enable = false;
  hardware.nvidia.enable = true;

  services.greetd = let
    session.user = "nr";
    session.command = "${my.pkgs.herbstluftwm.override {
      drivers.nvidia = config.hardware.nvidia.package.bin;
    }}/scripts/startx";  
  in {
    enable = true;
    settings.default_session = session;
    settings.initial_session = session;
  };
  
  persist.directories = [
    "/var/lib/alsa"
    "/var/lib/bluetooth"
    "/etc/NetworkManager"
    "/etc/ssh" 
  ];
  
  systemd.packages = with my.pkgs; [
    unclutter.service
    dunst.service
  ];
  
  systemd.user.targets.graphical-session.wants = [
    "unclutter.service"
    "dunst.service"
  ];

  environment.etc."xdg/mimeapps.list".source = my.pkgs.mimeapps;

  
  home.nr = {
    shell = (my.pkgs.zsh.override {
      variables."CARGO_HOME" = "$XDG_CONFIG_HOME/cargo";
    });
    
    persist.directories = [
      "Downloads"
      "media"
      "dev"
      "config"
      ".config/Bitwarden"
      ".config/spotify"
      ".config/pulse"
      ".config/cargo"
      ".config/filezilla"
      ".local/share/direnv"
      ".local/share/qutebrowser"
      ".local/state/zsh/history"
      ".mozilla/firefox"
      ".ssh"
    ];

    packages = with my.pkgs; [
      rofi
      firefox
      git
      alacritty
      helix
      qutebrowser
      zathura
      bottom
      ssh
      mpv
      joshuto
      imv
      gucharmap
      thunar
      filezilla
      lxappearance
      nix-index
      gitui
      direnv
    ] ++ (with pkgs; [
      spotify
      discord
      # bitwarden
      unzip
      fontpreview
      neofetch
      parsec-bin
    ]);
  };
}

