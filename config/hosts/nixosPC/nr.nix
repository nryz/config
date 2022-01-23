{ config, lib, pkgs, inputs, blocks, ... }: {

imports = with blocks; [
  profiles.desktop { theme = {
    background =  "11";
    colorscheme = "gruvbox-dark-soft";

    gapSize = 12;

    font.name = "System-ui regular"; 
    font.size = 10;

    gtk.theme.package = pkgs.vimix-gtk-themes; 
    gtk.theme.name = "vimix-dark-laptop-ruby";
    gtk.iconTheme.package = pkgs.vimix-icon-theme; 
    gtk.iconTheme.name = "Vimix Ruby Dark";
  }; }

  desktop.qtile
  desktop.picom
  desktop.x11

  projects.keyboard
  projects.nixpkgs

  games.minecraft
  games.dwarf-fortress
  games.steam
  games.lutris

  sites.youtube
  sites.reddit

  programs.neovim
  programs.kitty
  programs.zsh
  programs.fzf
  programs.git
  programs.firefox
  programs.helix
  programs.kakoune
  programs.mpv
  programs.ncmpcpp
  programs.qutebrowser
  programs.vieb
  programs.ranger
  programs.spotify
  programs.sway-launcher-desktop
  programs.zathura
  programs.nix-index
  programs.passage {
    passage.storeLocation = "/run/media/nr/PASSAGE/passage/store";
    passage.identitiesLocation = "/run/media/nr/PASSAGE/passage/identities";
  }

  services.dunst
  services.udiskie
  services.unclutter
]; 

}
