{ config, lib, pkgs, ... }:

{
  environment = {
    pathsToLink = ["/share/zsh" "/share/fish" "/share/bash"];
    variables.EDITOR = "vim";
    variables.VISUAL = "vim";
  };

  services.fwupd.enable = true;
  programs.dconf.enable = true;

  hardware = {
    enableAllFirmware = true;
    cpu.intel.updateMicrocode = true;
  };


  fonts = {
    enableDefaultFonts = true;
    fontDir.enable = true;
    fonts = with pkgs; [
      fira-code
     (nerdfonts.override { fonts = [ "Iosevka" ];})
    ];

    fontconfig = {
      enable = true;

      defaultFonts = {
        monospace = ["fira-code"];
        #sansSerif = [];
        #serif = [];
      };
    };
  };

  time.hardwareClockInLocalTime = true;

  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };

  environment.systemPackages = with pkgs; [
    nix-prefetch-scripts
    nixos-option
    manix
    lshw
    usbutils
    xclip
    wget
    htop
    fup-repl
    moreutils
  ];
}
