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
    unclutter.service
    dunst.service
  ];
  
  systemd.user.targets.graphical-session.wants = [
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
  ] ++ (with pkgs; [
    spotify
    discord
    bitwarden
    unzip
    fontpreview
    neofetch
  ]);
  
}

