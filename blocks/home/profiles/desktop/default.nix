{ config, lib, pkgs, inputs, ... }:

with lib;
with lib.my;
let
  addDesktop = app:
    app + ".desktop";

    theme = config.theme;
in
{
  options.theme = with types; {
    background = mkOpt' str;

    gapSize = mkOpt' int;

    font = mkOpt' (nullOr hm.types.fontType);

    gtk.theme = {
      package = mkOpt' (nullOr package);
      name = mkOpt' str;
    };

    gtk.iconTheme = {
      package = mkOpt' (nullOr package);
      name = mkOpt' str;
    };
  };

  config = {
    home.packages = with pkgs; [
      lxappearance
      gnome-icon-theme

      unzip

      xplr
      xfce.thunar
      tmpmail
      ueberzug
      feh
      sxiv
      st
      libqalculate
      android-tools
      gnome.gucharmap
      scrot
      imagemagick
      fontpreview
      neofetch

      tree
      lsd
      bat
      fd
      ripgrep
    ];

    scheme = pkgs.base16-colorscheme;

    gtk = {
      enable = true;

      theme = theme.gtk.theme;
      iconTheme = theme.gtk.iconTheme;
      font = theme.font;
    };


    home.file."${config.home.homeDirectory}/Pictures/backgrounds" = {
      recursive = true;
      source = config.sourcePath + /backgrounds;
    };

    systemd.user.services.background = {
      Unit = {
        Description = "set background";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.feh}/bin/feh --bg-fill --no-fehbg ${config.home.homeDirectory}/Pictures/backgrounds/${config.theme.background}";
        IOSchedulingClass = "idle";
      };

      Install = { WantedBy = [ "graphical-session.target" ]; };
    };

    systemd.user.startServices = "sd-switch";

    home.shellAliases = {
      cat = "bat";
      tree = "tree --dirsfirst";
      rg = "rg --no-messages";
      trash-empty = "trash-empty --trash-dir=${config.home.homeDirectory}/.local/share/Trash";
      c = "cd ${config.configPath}";
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
