{ config, lib, pkgs, inputs, flakePath, ... }:

with lib;
with lib.my;
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

    system.udevPackages = mkOpt (listOf package) [];
    system.udevRules = mkOpt lines '''';
    system.programs = mkOpt (listOf str) [];
  };

  config = {
    blocks.desktop.enable = true;

    systemd.user.startServices = "sd-switch";

    scheme = flakePath + /data/colourschemes + "/${config.blocks.desktop.colourscheme}.yaml";

    home.shellAliases = {
      cat = "bat";
      tree = "tree --dirsfirst";
      rg = "rg --no-messages";
    };

    home.sessionVariables = {
      EDITOR = config.defaults.editor;
      VISUAL = config.defaults.editor;
    };

    xdg = {
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
