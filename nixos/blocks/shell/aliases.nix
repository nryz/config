{ config, lib, pkgs, ... }:

with lib;
with lib.my;
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
    ];

    hm.home.shellAliases = {
      lsd = "lsd --group-directories-first -1";
      cat = "bat";
      tree = "tree --dirsfirst";
      rg = "rg --no-messages";
    };
  };
}