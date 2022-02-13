{ config, lib, pkgs, extraPkgs, inputs, ... }: 

with lib;
with lib.my;
let
  systemInfo = config.systemInfo;
  sa = systemInfo.scalability;
in {

  blocks = mkMerge [({
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

    persist.enable = true;

    desktop.qtile.enable = true;
    desktop.sway.enable = false;

    sites.youtube.enable = true;

    programs.btop.enable = true;
    programs.neovim.enable = true;

    programs.kitty.enable = true;

    programs.zsh.enable = true;
    programs.fzf.enable = true;
    programs.git.enable = true;
    programs.mpv.enable = true;
    programs.ncmpcpp.enable = true;
    programs.qutebrowser.enable = true;
    programs.lf.enable = true;
    programs.imv.enable = true;
    programs.spotify.enable = true;
    programs.sway-launcher-desktop.enable = true;
    programs.zathura.enable = true;
    programs.nix-index.enable = true;
    programs.passage = {
      enable = true;
      storeLocation = "/run/media/nr/FDP/passage";
    };

    services.dunst.enable = true;
    services.udiskie.enable = true;
    services.unclutter.enable = true;
  })
  (mkIf (sa.diskSpace > 1) {
    projects.keyboard.enable = true;
    programs.firefox.enable = true;
    programs.helix.enable = true;
    programs.kakoune.enable = true;
  }) 
  (mkIf (sa.gpu > 1 && sa.diskSpace > 1 && sa.cpu > 1) {
    games.minecraft.enable = false;
    games.dwarf-fortress.enable = false;
    games.steam.enable = false;
    games.lutris.enable = false;
  })];

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
