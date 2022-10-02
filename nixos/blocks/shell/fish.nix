{ config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.blocks.shell.fish;
in
{
  options.blocks.shell.fish = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    blocks.persist.userFiles = [ ".local/share/fish" ];

    hm.programs.fish = {
      enable = true;

      functions = {
        fish_user_key_bindings = "fzf_key_bindings";
      };

    };
  };
}
