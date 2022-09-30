{ config, lib, pkgs, extraPkgs, inputs, defaultUser, ... }: 

with lib;
with lib.my;
{
  blocks = {
    persist.enable = true;

    desktop = {
      herbstluftwm.enable = true;
      riverwm.enable = false;
      
      eww.enable = true;

      background =  "24";
      colourscheme = "solarized-dark";

      font.package = pkgs.source-code-pro;
      font.name = "Source Code Pro";
      font.size = 9;

      gtk.package = pkgs.vimix-gtk-themes; 
      gtk.name = "vimix-dark-laptop-ruby";
      gtkIcon.package = pkgs.vimix-icon-theme; 
      gtkIcon.name = "Vimix Ruby Dark";
    };

    programs = {
      btop.enable = true;
      kitty.enable = true;
      zsh.enable = true;
      direnv.enable = true;
      fzf.enable = true;
      git.enable = true;
      mpv.enable = true;
      qutebrowser.enable = true;
      lf.enable = true;
      bitwarden.enable = true;
      imv.enable = true;
      spotify.enable = true;
      rofi.enable = true;
      zathura.enable = true;
      nix-index.enable = true;
      filezilla.enable = true;
      firefox.enable = true;
      helix.enable = true;
    };

    services = {
      dunst.enable = true;
      udiskie.enable = true;
      unclutter.enable = true;
    };

    projects.keyboard.enable = true;

    games = {
      minecraft.enable = false;
      dwarf-fortress.enable = false;
      steam.enable = false;
      lutris.enable = false;
    };
  };

  home.packages = with pkgs; [
    tree
    lsd
    bat
    fd
    ripgrep
    unzip
    lxappearance
    xplr
    xfce.thunar
    tmpmail
    ueberzug
    st
    libqalculate
    android-tools
    gnome.gucharmap
    imagemagick
    fontpreview
    neofetch
  ];
}
