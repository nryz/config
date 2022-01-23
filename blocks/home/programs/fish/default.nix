{ config, lib, pkgs, ... }:

{
  persist.files = [ ".local/share/fish" ];

  programs.fish = {
    enable = true;

    functions = {
      fish_user_key_bindings = "fzf_key_bindings";
    };

    shellInit = ''
      set -x MANPAGER nvim +Man!
    '';
  };
}
