{ config, lib, pkgs, extraPkgs, inputs, blocks, systemInfo, ... }: 
let
  sa = systemInfo.scalability;
in {

  imports = with blocks; [
    persist

    desktop.qtile
    #desktop.sway

    sites.youtube

    programs.btop
    programs.neovim
    programs.kitty
    programs.zsh
    programs.fzf
    programs.git
    programs.mpv
    programs.ncmpcpp
    programs.qutebrowser
    programs.lf
    programs.imv
    programs.spotify
    programs.sway-launcher-desktop
    programs.zathura
    programs.nix-index
    programs.passage {
      passage.storeLocation = "/run/media/nr/FDP/passage";
    }

    services.dunst
    services.udiskie
    services.unclutter
  ] ++ lib.optionals (sa.diskSpace > 1) [
    projects.keyboard
    programs.firefox
    programs.helix
    programs.kakoune
  ] ++ lib.optionals (sa.gpu > 1 && sa.diskSpace > 1 && sa.cpu > 1) [
    # games.minecraft
    # games.dwarf-fortress
    # games.steam
    # games.lutris
  ]; 

  theme = {
    background =  "10";
    colour = "solarized-dark";

    wm.gap = 12;
    wm.border = 2;
    wm.bar.enable = true;
    wm.bar.size  = 22;


    font.name = "System-ui regular"; 
    font.size = 10;

    gtk.theme.package = pkgs.vimix-gtk-themes; 
    gtk.theme.name = "vimix-dark-laptop-ruby";
    gtk.iconTheme.package = pkgs.vimix-icon-theme; 
    gtk.iconTheme.name = "Vimix Ruby Dark";
  };

  home.packages = with pkgs; [
    tree
    lsd
    bat
    fd
    ripgrep
    unzip
  ] ++ lib.optionals (sa.diskSpace > 1) [
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
