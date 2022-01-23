{ config, lib, pkgs, ... }:

{
  programs.git = {
    enable = true;

    userEmail = "ron.vnessen@gmail.com";
    userName = "nryz";
  };

  home.packages = with pkgs; [
    gitui
  ];
}
