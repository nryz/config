{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [ ranger ];
  
  xdg.configFile."ranger/rc.conf".text = ''
    set preview_images true
    set preview_images_method kitty
    set draw_borders both
    set dirname_in_tabs true
  '';
}
