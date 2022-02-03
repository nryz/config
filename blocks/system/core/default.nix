{ config, lib, pkgs, inputs, ... }:

with lib;
with lib.my;
let
  isFlagEnabled = flag:
        any (v: v == flag) (flatten (mapAttrsToList (n: v: 
      v.system.programs) config.home-manager.users ));

  theme = config.theme;
in
{
  options.theme = with types; {
    background = mkOpt' str;
  };

  config = {
    services.udev.packages = [] ++ (flatten (mapAttrsToList (n: v: 
      v.system.udevPackages ) config.home-manager.users));

    programs.steam.enable = (isFlagEnabled "steam");

    scheme = pkgs.base16-colorscheme;

    boot = {
      #kernelPackages = pkgs.linuxPackages_latest;

      loader =  {
        timeout = 1;
        systemd-boot = {
          enable = true;
          configurationLimit = 5;
          consoleMode = "auto";
          editor = false;
        };
        efi.canTouchEfiVariables = true;
      };

    };

    time.timeZone = "Europe/London";

    nix = {
      package = pkgs.nixFlakes;
      extraOptions = ''
        experimental-features = nix-command flakes
        warn-dirty = false
      '';

      gc = {
        automatic = true;
        options = "--delete-older-than 5d";
      };

      settings = {
        auto-optimise-store = true;
      };
    };
  };
}
