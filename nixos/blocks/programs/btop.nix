{ config, lib, libs, pkgs, ... }:

with lib;
with libs.flake;
let
  cfg = config.blocks.programs.btop;
in
{
  options.blocks.programs.btop = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    hm.home.packages = with pkgs; [
      btop
    ];

    hm.xdg.configFile."btop/btop.conf".text = ''
      color_theme = "TTY"
      theme_background = False
      rounded_corners = True
      graph_symbol = "braille"
      vim_keys = True
      shown_boxes = "cpu proc mem net"

      #* Format: "box_name:P:G,box_name:P:G" P=(0 or 1) for alternate positions, G=graph symbol to use for box.
      #* Use withespace " " as separator between different presets.
      #* Example: "cpu:0:default,mem:0:tty,proc:1:default cpu:0:braille,proc:0:tty"
      presets = "cpu:0:default,proc:0:default cpu:0:default,mem:0:default"

      disks_filter = "/ /nix /boot"
    '';
  };
}
