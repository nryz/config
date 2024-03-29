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

  boot.kernelModules = [ "xpad" "joydev" ];
  boot.extraModulePackages = [ pkgs.xpad ];

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
      ".config/Bitwarden"
      ".config/spotify"
      ".config/pulse"
      ".config/cargo"
      ".config/filezilla"
      ".config/seedbox"
      ".config/deluge"
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

  programs.steam.enable = true;

  users.users.nr = {
    passwordFile = "/nix/passwords/nr";

    shell = config.mypkgs.zsh.override {
      env."CARGO_HOME" = "$XDG_CONFIG_HOME/cargo";
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
        yazi
        imv
        gucharmap
        thunar
        lxappearance
        nix-index
        gitui
        direnv
      ]
      ++ (with pkgs; [
        antimicrox
        (pkgs.writeShellScriptBin "gamepad-mouse" ''
          antimicrox --profile ${./gamepad_mouse_input.gamecontroller.amgp}
        '')
        spotify
        discord
        neofetch
        parsec-bin
        deluge
        tor-browser-bundle-bin
        (pkgs.writeShellScriptBin "seedbox-enter" ''
          if [ -f ~/.config/seedbox/server ]; then
            mkdir ~/seedbox
            server=`cat ~/.config/seedbox/server`

            if ${pkgs.sshfs}/bin/sshfs \
              -o uid=`id -u $USER` \
              -o gid=`id -g $USER` \
              -o allow_other,default_permissions \
              $server ~/seedbox;
            then
                cwd=$(pwd)
                cd ~/seedbox
                $SHELL
                cd $cwd
                umount ~/seedbox
                rmdir ~/seedbox
            fi

            rmdir ~/seedbox
          fi
        '')
      ]);
  };
}
