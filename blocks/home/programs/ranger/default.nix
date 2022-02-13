{ config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.blocks.programs.ranger;
in
{
  options.blocks.programs.ranger = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ ranger ];
    
    xdg.configFile."ranger/rc.conf".text = ''
      set preview_images true
      set preview_images_method kitty
      set draw_borders both
      set dirname_in_tabs true
    '';
  };
}
