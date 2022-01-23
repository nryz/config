{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    helix
  ];

  xdg.configFile."helix/config.toml".text = ''
    [editor]
    auto-pairs = false
    line-number = "relative"

    [lsp]
    display-messages = true
  '';
}
