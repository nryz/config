{ config, lib, pkgs, ... }:

{
  programs.git = {
    enable = true;

    userEmail = "mail@nryz.xyz";
    userName = "nryz";
  };

  home.packages = with pkgs; [
    gitui
  ];
}
