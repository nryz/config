{ config, lib, libs, pkgs, info, ... }:

with lib;
with libs.flake;
let
  addDesktop = app:
    app + ".desktop";
in
{
  options = with types; {
    defaults = {
      editor = mkOpt str "hx";
      shell = mkOpt str "zsh";
      terminal = mkOpt str "kitty";
      browser = mkOpt str "org.qutebrowser.qutebrowser";
      fileManager = mkOpt str "ranger";
      imageViewer = mkOpt str "imv";
      videoPlayer = mkOpt str "mpv";
      pdfViewer = mkOpt str "zathura";
    };
  };

  config = {
    hm.xdg = {
      enable = true;

      userDirs = {
        enable = false;
        createDirectories = false;
      };

      mimeApps = {
        enable = true;

        #https://www.iana.org/assignments/media-types/media-types.xhtml
        defaultApplications = {
          "image/jpeg" = [ (addDesktop config.defaults.imageViewer) ];
          "image/png" = [ (addDesktop config.defaults.imageViewer) ];
          "x-scheme-handler/file" = [ (addDesktop config.defaults.fileManager) ];
          "text/plain" = [ (addDesktop config.defaults.editor) ];
          "application/pdf" = [ (addDesktop config.defaults.pdfViewer) ];
          "video/mpeg" = [ (addDesktop config.defaults.videoPlayer) ];

          #browser
          "x-scheme-handler/http" = [ (addDesktop config.defaults.browser) ];
          "x-scheme-handler/https" = [ (addDesktop config.defaults.browser) ];
          "x-scheme-handler/ftp" = [ (addDesktop config.defaults.browser) ];
          "application/xhtml+xml" = [ (addDesktop config.defaults.browser) ];
          "application/xml" = [ (addDesktop config.defaults.browser) ];
          "application/rdf+xml" = [ (addDesktop config.defaults.browser) ];
          "text/html" = [ (addDesktop config.defaults.browser) ];
          "text/xml" = [ (addDesktop config.defaults.browser) ];
        };
      };
    };
  };
}
