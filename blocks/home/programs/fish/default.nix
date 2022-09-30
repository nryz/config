{ config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.blocks.programs.fish;
in
{
  options.blocks.programs.fish = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    blocks.persist.files = [ ".local/share/fish" ];

    programs.fish = {
      enable = true;

      functions = {
        fish_user_key_bindings = "fzf_key_bindings";
      };

    };
  };
}
