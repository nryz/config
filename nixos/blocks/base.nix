{ config, options, lib, pkgs, info, ... }:

with lib;
with lib.my;
{
  options = with types; {
    hm = mkOpt attrs {};
    
    hm-read-only = mkOpt attrs {};
  };

  config = {
    system.stateVersion = info.stateVersion;
    networking.hostName = info.hostName;

    nixpkgs.config = pkgs.config;
    nixpkgs.pkgs = pkgs;

    users = {
      mutableUsers = false;
      defaultUserShell = pkgs.zsh;
      
      users.${info.user} = {
        shell = pkgs."${config.defaults.shell}";
        extraGroups = [ "wheel" ];
        isNormalUser = true;
        passwordFile = "/etc/passwords/${info.user}";
        uid = 1000;
      };

      users.root.hashedPassword = "!";
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "HMBACKUP";

      users.${info.user} = mkAliasDefinitions options.hm;
    };

    hm-read-only = config.home-manager.users.${info.user};
   
    blocks.desktop.enable = true;

    hm = {
      home.username = info.user;
      home.homeDirectory = "/home/${info.user}";
      home.stateVersion = info.stateVersion;
      programs.home-manager.enable = true;

      systemd.user.startServices = "sd-switch";

      home.sessionVariables = {
        EDITOR = config.defaults.editor;
        VISUAL = config.defaults.editor;
      };
    };

    
    # TODO: fix this
    # nscd fails due to start-limit-hit
    systemd.services.nscd.serviceConfig = {
      StartLimitBurst = 20;
    };

    scheme = info.flakePath + /nixos/data/colourschemes + "/${config.blocks.desktop.colourscheme}.yaml";

    systemd.enableEmergencyMode = false;

    environment = {
      pathsToLink = ["/share/${config.defaults.shell}"];
      variables.EDITOR = config.defaults.editor;
      variables.VISUAL = config.defaults.editor;
    };

    services.fwupd.enable = true;
    programs.dconf.enable = true;

    hardware = {
      enableAllFirmware = true;
      cpu.intel.updateMicrocode = true;
    };

    fonts = {
      enableDefaultFonts = true;
      fontDir.enable = true;
      fonts = with pkgs; [ (nerdfonts.override { fonts = [ "Iosevka" ];}) ];
    };

    time.hardwareClockInLocalTime = true;

    systemd.targets = {
      sleep.enable = false;
      suspend.enable = false;
      hibernate.enable = false;
      hybrid-sleep.enable = false;
    };

    environment.systemPackages = with pkgs; [
      nix-prefetch-scripts
      nixos-option
      manix
      lshw
      usbutils
      xclip
      wget
      fup-repl
      moreutils
    ];

    #some checks so I don't mess up my system
    assertions = [
      {
        assertion = lib.hasAttr "/etc/passwords" config.fileSystems;
        message = "no passwords dir in fileSystems";
      }
      {
        assertion = lib.hasAttr "/" config.fileSystems;
        message = "no root in fileSystems";
      }
      {
        assertion = lib.hasAttr "/nix" config.fileSystems;
        message = "no nix in fileSystems";
      }
      {
        assertion = lib.hasAttr "/boot" config.fileSystems;
        message = "no boot in fileSystems";
      }
    ];
  };
}
