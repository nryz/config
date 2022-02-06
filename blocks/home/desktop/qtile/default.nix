{ config, lib, pkgs, inputs, blocks, ... }:

with lib;
with lib.my;
let
  qtile-python-packages = pkgs.python3.withPackages (p: with p; [
      python
      mypy
      psutil
      dbus-next
  ]);
in
{
  imports = with blocks; [
    desktop.x11
  ];

  persist.directories = [ ".local/share/qtile" ];

  home.packages = [
    pkgs.qtile
  ];

  home.sessionVariables = {
    PYTHONPATH = "${qtile-python-packages}/${qtile-python-packages.sitePackages}";
  };

  xsession.windowManager.command = "${pkgs.qtile}/bin/qtile start";

  xdg.configFile."qtile/defaults.py".text = ''
    terminal = '${config.defaults.terminal}'
  '';

  xdg.configFile."qtile/theme.py".text = with config.scheme.withHashtag; 
  ''
    gapSize = ${toString config.theme.wm.gap}
    borderSize = ${toString config.theme.wm.border}
    barSize = ${toString config.theme.wm.bar.size}
    enableBar = ${toString config.theme.wm.bar.enable}

    base00 = "${base00}"
    base01 = "${base01}"
    base02 = "${base02}"
    base03 = "${base03}"
    base04 = "${base04}"
    base05 = "${base05}"
    base06 = "${base06}"
    base07 = "${base07}"
    base08 = "${base08}"
    base09 = "${base09}"
    base0A = "${base0A}"
    base0B = "${base0B}"
    base0C = "${base0C}"
    base0D = "${base0D}"
    base0E = "${base0E}"
    base0F = "${base0F}"

    barBg = "${base01 + toHexString 200}"
    barBorderBg = "${base00 + toHexString 200}"
  '';

  xdg.configFile."qtile" = {
    recursive = true;
    source = ./files;
  };
}
