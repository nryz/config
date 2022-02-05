
{ config, lib, pkgs, extraPkgs, inputs, blocks, ... }:

with lib;
with lib.my;
let
  isFlagEnabled = flag:
        any (v: v == flag) (flatten (mapAttrsToList (n: v: 
      v.system.programs) config.home-manager.users ));
in
{
   imports = with blocks; [ 
     boot
     scripts 
     nix
   ];

  options.persist = with types; {
    directories = mkOpt (listOf str) [];
    files = mkOpt (listOf str) [];
    path = mkOpt' str;
  };

  config = {
    services.udev.packages = [] ++ (flatten (mapAttrsToList (n: v: 
      v.system.udevPackages ) config.home-manager.users));

    programs.steam.enable = (isFlagEnabled "steam");

    scheme = extraPkgs.base16-colorscheme;

    systemd.enableEmergencyMode = false;

    environment = {
      pathsToLink = ["/share/zsh" "/share/fish" "/share/bash"];
      variables.EDITOR = "vim";
      variables.VISUAL = "vim";
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
        fira-code
       (nerdfonts.override { fonts = [ "Iosevka" ];})
      ];

      fontconfig = {
        enable = true;

        defaultFonts = {
          monospace = ["fira-code"];
          #sansSerif = [];
          #serif = [];
        };
      };
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
