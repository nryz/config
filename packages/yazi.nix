
{
  inputs,
  pkgs,
  my,
  wrapPackage,
  base16,
  naersk,
  editor,
}: let
  lib = pkgs.lib;
in
  wrapPackage {
    pkg = pkgs.yazi;
    name = "yazi";

    alias = "yi";

    binPath = with pkgs; [ ueberzugpp ];
  }
