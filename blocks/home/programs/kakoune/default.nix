{ config, lib, pkgs, inputs, ... }:

{
  xdg.configFile."kak/colors/base16-scheme.kak".text = 
    builtins.readFile (config.scheme inputs.base16-kakoune);

  programs.kakoune = {
    enable = true;

    config = {
      colorScheme = "base16-scheme";
    };
  };
}
