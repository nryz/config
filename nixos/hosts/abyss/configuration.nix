{ profiles, inputs, config, lib, pkgs, my, ... }: 

{
  imports = [ 
    profiles.desktop
    inputs.impermanence.nixosModules.impermanence
    ./udev-rules.nix 
  ];
  
  time.timeZone = "Europe/London";

  profile.bluetooth.enable = false;
  profile.nvidia.enable = true;

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

  programs.fuse.userAllowOther = true;

  environment.persistence."/nix/persist/system" = {
      hideMounts = true;

      directories = [
        "/var/log"
        "/var/lib/systemd/coredump"
        "/var/db/sudo/lectured"
        "/var/lib/alsa"
        "/var/lib/bluetooth"
        "/etc/NetworkManager"
        "/etc/ssh" 
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
  
  systemd.packages = with my.pkgs; [
    unclutter.service
    dunst.service
  ];

  systemd.user.services.dunst.wantedBy = [ "graphical-session.target" ];
  systemd.user.services.unclutter.wantedBy = [ "graphical-session.target" ];

  environment.etc."xdg/mimeapps.list".source = my.pkgs.mimeapps;

  environment.pathsToLink = [ "/share/zsh" ];

  users.users.nr = {
    shell = (my.pkgs.zsh.override {
      variables."CARGO_HOME" = "$XDG_CONFIG_HOME/cargo";
    });

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

