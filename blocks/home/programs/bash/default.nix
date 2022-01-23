{ config, lib, pkgs, ... }:

{
  persist.files = [ ".bash_history" ];

  programs.bash = {
    enable = true;

    initExtra = ''
      export MANPAGER="nvim +Man!"
    '';
  };
}
