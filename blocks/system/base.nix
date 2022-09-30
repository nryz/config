{ config, lib, pkgs, extraPkgs, inputs, flakePath, ... }:

with lib;
with lib.my;
let
  isFlagEnabled = flag:
        any (v: v == flag) (flatten (mapAttrsToList (n: v: 
      v.system.programs) config.home-manager.users ));
in
{
  options.blocks = with types; {
    colourscheme = mkOpt' str;
  };

  config = {
    blocks.boot.enable = true;
    blocks.nix.enable = true;

    # TODO: fix this
    # nscd fails due to start-limit-hit
    systemd.services.nscd.serviceConfig = {
      StartLimitBurst = 20;
    };

    services.udev.packages = [] ++ (flatten (mapAttrsToList (n: v: 
      v.system.udevPackages ) config.home-manager.users));
      
    services.udev.extraRules = concatStrings (mapAttrsToList (n: v: 
      v.system.udevRules) config.home-manager.users);

    programs.steam.enable = (isFlagEnabled "steam");

    scheme = flakePath + /data/colourschemes + "/${config.blocks.colourscheme}.yaml";

    systemd.enableEmergencyMode = false;

    environment = {
      pathsToLink = ["/share/zsh" "/share/fish" "/share/bash"];
      variables.EDITOR = "hx";
      variables.VISUAL = "hx";
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
      fonts = with pkgs; [
        # fira-code
       (nerdfonts.override { fonts = [ "Iosevka" ];})
      ];

      # fontconfig = {
      #   enable = true;

      #   defaultFonts = {
      #     monospace = ["fira-code"];
      #     #sansSerif = [];
      #     #serif = [];
      #   };
      # };
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
  };
}
