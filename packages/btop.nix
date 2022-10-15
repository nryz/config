{ pkgs, my, ... }:

let
    configFile = ''
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

in my.lib.wrapPackageJoin {
  pkg = pkgs.btop;
  name = "btop";

  # Currently doesn't work
  # Presumably btop doesn't like XDG_CONFIG_HOME in read only dir
  vars = { 
    "XDG_CONFIG_HOME" = "${placeholder "out"}/config";
  };

  files = {
    "config/btop/btop.conf" = pkgs.writeText "btop.conf" configFile;
  };
}
