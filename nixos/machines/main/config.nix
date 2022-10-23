{ config, lib, pkgs, my, ... }: 

with lib;
{
  imports = [ ./udev.nix ];
  
  time.timeZone = "Europe/London";

  bluetooth.enable = false;
  hardware.nvidia.enable = true;
  
  services.greetd = let
    session.user = "nr";
    session.command = "${my.pkgs.startx.override {
      wm = my.pkgs.herbstluftwm;
      drivers = [{
        name = "nvidia";
        package = config.hardware.nvidia.package.bin;
      }];
    }}/bin/startx";  
  in {
    enable = true;
    settings.default_session = session;
    settings.initial_session = session;
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
    alacritty
    helix
    qutebrowser
    zathura
    btop
    ssh
    mpv
    joshuto
    imv
    gucharmap
    thunar
    filezilla
    lxappearance
    nix-index
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

