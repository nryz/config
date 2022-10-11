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
  
  my.persist.enable = true;
  my.state.user.directories = [
    ".config/Bitwarden"
    ".config/spotify"
    ".local/share/direnv"
    ".local/share/qutebrowser"
    ".mozilla/firefox/default"
  ];
  
  #TODO: Add this to the zsh shell my.pkg
  hm.programs.zsh.initExtra = ''
     eval "$(${my.pkgs.direnv}/bin/direnv hook zsh)"
  '';
  
  blocks.shell = {
    aliases.enable = true;
    zsh.enable = true;
  };
  
  blocks.programs = {
    fzf.enable = true;
  };

  hm.home.packages = with my.pkgs; [
    firefox
    git
    kitty
    helix
    qutebrowser
    zathura
    btop
    mpv
    lf
    imv
  ] ++ (with pkgs; [
    gitui
    spotify
    bitwarden
    filezilla
    unzip
    lxappearance
    xplr
    xfce.thunar
    ueberzug
    libqalculate
    android-tools
    gnome.gucharmap
    imagemagick
    fontpreview
    neofetch
  ]);
  

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

