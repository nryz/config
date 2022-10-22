{ config, lib, pkgs, my, ... }: 

with lib;
{
  imports = [ ./udev.nix ];
  
  time.timeZone = "Europe/London";

  bluetooth.enable = false;
  hardware.nvidia.enable = true;
  
  services.greetd = rec {
    enable = true;
    settings.default_session = {
      user = "nr";
      command = "${my.pkgs.startx.override {
          wm = my.pkgs.herbstluftwm;
          drivers = [{
            name = "nvidia";
            package = config.hardware.nvidia.package.bin;
          }];
        }}/bin/startx
      ";
    };
    settings.initial_session = settings.default_session;
  };
  
  my.persist.users = ["nr"];
  my.state = {
    directories = [
      "/var/lib/alsa"
      "/var/lib/bluetooth"
      "/etc/NetworkManager"
      "/etc/ssh" 

      ".config/Bitwarden"
      ".config/spotify"
      ".config/pulse"
      ".local/share/direnv"
      ".local/share/qutebrowser"
      ".local/state/zsh/history"
      ".mozilla/firefox/default"
      ".ssh"
    ];
  };
  
  users.defaultUserShell = my.pkgs.zsh;
  environment.pathsToLink = ["/share/zsh"];
  
  systemd.packages = with my.pkgs; [
    picom.service
    unclutter.service
    dunst.service
  ];
  
  systemd.user.targets.graphical-session.wants = [
    "picom.service"
    "unclutter.service"
    "dunst.service"
  ];
  

  users.users.nr.packages = with my.pkgs; [
    rofi
    firefox
    git
    kitty
    helix
    qutebrowser
    zathura
    btop
    ssh
    mpv
    lf
    imv
    gucharmap
    thunar
    filezilla
    lxappearance
  ] ++ (with pkgs; [
    gitui
    spotify
    discord
    bitwarden
    unzip
    fontpreview
    neofetch
  ]);
  
}

