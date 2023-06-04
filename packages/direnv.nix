{
  pkgs,
  my,
  wrapPackage,
}:
wrapPackage {
  pkg = pkgs.direnv;
  name = "direnv";

  vars = {
    "XDG_CONFIG_HOME" = "${placeholder "out"}/config";
  };

  files = {
    "config/direnv/direnvrc" = ''
      source ${pkgs.nix-direnv}/share/nix-direnv/direnvrc
    '';
  };
}
