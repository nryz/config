{ config, lib, pkgs, inputs, ... }:

with lib;
with lib.my;
{
  config.persist = {
    directories = [
      "Downloads"
      "Music"
      "Pictures"
      "Documents"
      "Videos"
      "Projects"
      "Config"
      ".ssh"
      ".gnupg"
      ".cache/nix-index"
      ".local/share/Trash"
      ".local/share/nix"
    ];
  };
}
