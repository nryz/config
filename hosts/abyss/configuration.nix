{
  nixosModules,
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    nixosModules.desktop-profile
    nixosModules.impermanence
    ./hardware-configuration.nix
    ./disk-configuration.nix
    ./udev-rules.nix
  ];

  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  networking.hostName = "abyss";

  time.timeZone = "Europe/London";

  profile.bluetooth.enable = false;
  profile.nvidia.enable = true;

  host-scripts.type = "desktop";
  host-scripts.backup = [
    "/home/nr/dev"
    "/home/nr/media"
    "/etc/nix/secret-keys"
  ];

  services.greetd = let
    session.user = "nr";
    session.command = "${config.mypkgs.herbstluftwm.override {
      drivers.nvidia = config.hardware.nvidia.package.bin;
    }}/scripts/startx";
  in {
    enable = true;
    settings.default_session = session;
    settings.initial_session = session;
  };

  programs.fuse.userAllowOther = true;

  environment.persistence."/nix/persist/system" = {
    hideMounts = true;

    directories = [
      "/tmp"
      "/var/log"
      "/var/lib/systemd/coredump"
      "/var/db/sudo/lectured"
      "/var/lib/alsa"
      "/var/lib/bluetooth"
      "/etc/NetworkManager"
      "/etc/ssh"
      "/etc/nix/secret-keys"
    ];

    files = [
      # "/etc/machine-id"
    ];
  };

  environment.persistence."/nix/persist" = {
    hideMounts = true;

    users.nr.directories = [
      "downloads"
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
  };

  systemd.packages = with config.mypkgs; [
    unclutter.service
    dunst.service
  ];

  systemd.user.services.dunst.wantedBy = ["graphical-session.target"];
  systemd.user.services.unclutter.wantedBy = ["graphical-session.target"];

  environment.etc."xdg/mimeapps.list".source = config.mypkgs.mimeapps;

  environment.pathsToLink = ["/share/zsh"];

  users.users.nr = {
    passwordFile = "/nix/passwords/nr";

    shell = config.mypkgs.zsh.override {
      variables."CARGO_HOME" = "$XDG_CONFIG_HOME/cargo";
    };

    packages = with config.mypkgs;
      [
        rofi
        firefox
        git
        alacritty
        helix
        qutebrowser
        zathura
        bottom
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
      ]
      ++ (with pkgs; [
        spotify
        discord
        # bitwarden
        unzip
        fontpreview
        neofetch
        parsec-bin
        tor-browser-bundle-bin
      ]);
  };
}
