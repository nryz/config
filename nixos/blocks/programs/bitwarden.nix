{ config, options, pkgs, lib, my, ... }:

with lib;
with my.lib;
let
  cfg = config.blocks.programs.bitwarden;
in
{
  options.blocks.programs.bitwarden = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    my.state.user.directories = [ 
      ".config/Bitwarden"
    ];

    hm.home.packages = with pkgs; [
      bitwarden
    ];
  };
}
