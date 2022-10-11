{ config, lib, pkgs, my, ... }: 

with lib;
{
  time.timeZone = "Europe/London";

  blocks.desktop = {
    enable = true;

    herbstluftwm.enable = true;
    riverwm.enable = false;

    background =  "4";

    font.package = pkgs.source-code-pro;
    font.name = "Source Code Pro";
    font.size = 9;

    gtk.package = pkgs.vimix-gtk-themes; 
    gtk.name = "vimix-dark-laptop-ruby";
    gtkIcon.package = pkgs.vimix-icon-theme; 
    gtkIcon.name = "Vimix Ruby Dark";
  };
  
  blocks.shell = {
    aliases.enable = true;
    zsh.enable = true;
  };
  
  blocks.programs = {
    btop.enable = true;
    kitty.enable = true;
    direnv.enable = true;
    fzf.enable = true;
    git.enable = true;
    mpv.enable = true;
    qutebrowser.enable = true;
    lf.enable = true;
    bitwarden.enable = true;
    imv.enable = true;
    spotify.enable = true;
    zathura.enable = true;
    nix-index.enable = true;
    filezilla.enable = true;
    firefox.enable = true;
    helix.enable = true;
  };

  hm.home.packages = with pkgs; [
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
  
  my.persist.enable = true;

  blocks = {
    autologin.enable = true;

    network.enable = true;
    audio.enable = true;
    bluetooth.enable = true;

    services.ssh.enable = true;

    hardware.nvidia.enable = true; 
    hardware.ssd.enable = true; 
    virtualisation.enable = false;
    virtualisation.users = [ my.user ];

    services = {
      dunst.enable = true;
      unclutter.enable = true;
    };

    keyboard.enable = true;
  };
}

