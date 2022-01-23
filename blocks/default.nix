{ config, lib, pkgs, ... }:

with lib;
with lib.my;
{
  options = with types; {
    sourcePath = mkOpt' types.path;
    configPath = mkOpt' types.str;

    defaults = {
      editor = mkOpt str "vim";
      shell = mkOpt str "zsh";
      terminal = mkOpt str "kitty";
      browser = mkOpt str "qutebrowser";
      fileManager = mkOpt str "ranger";
      imageViewer = mkOpt str "sxiv";
      videoPlayer = mkOpt str "mpv";
      pdfViewer = mkOpt str "zathura";
    };
  };
}

