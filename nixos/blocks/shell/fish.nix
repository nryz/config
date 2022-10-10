{ config, options, pkgs, lib, my, ... }:

with lib;
with my.lib;
let
  cfg = config.blocks.shell.fish;
in
{
  options.blocks.shell.fish = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    my.state.user.files = [ ".local/share/fish" ];

    hm.programs.fish = {
      enable = true;

      functions = {
        fish_user_key_bindings = "fzf_key_bindings";
      };

    };
  };
}
