{ config, options, pkgs, lib, my, ... }:

with lib;
with my.lib;
let
  cfg = config.blocks.shell.aliases;
in
{
  options.blocks.shell.aliases = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    hm.home.packages = with pkgs; [
      ripgrep
      lsd
      bat
      tree
      fd
      sd
    ];

    hm.home.shellAliases = {
      lsd = "lsd --group-directories-first -1";
      cat = "bat";
      tree = "tree --dirsfirst";
      rg = "rg --no-messages";
    };
  };
}