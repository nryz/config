{ config, options, lib, pkgs, extraPkgs, inputs, flakePath, ... }:

with lib;
with lib.my;
{
  options.autoLoginUser = with types; mkOpt str "";
  options.theme.background = with types; mkOpt' str;

  config = {
    persist.directories = [ "/var/lib/sddm" ];

    environment.systemPackages = with pkgs; [
      (extraPkgs.sddm-theme.override {conf = with config.scheme.withHashtag; '' 
        [General]
        default_background=${flakePath}/data/backgrounds/${config.theme.background}
        font=Fira Code
        accent1=${base00}
        accent1_text=${base05}
        accent2=${base00}
        accent2_hover=${base0C}
        user_name=select
        primary_screen_only=true
        am_pm_clock=false
      '';})
      qt5.qtgraphicaleffects
      qt5.qtquickcontrols
    ];

    services.xserver = {
      enable = true;
      layout = "us";
      xkbOptions = "eurosign:e";

      monitorSection = ''
      Option "DPMS" "disable"
      '';

      serverFlagsSection  = ''
      Option "StandbyTime" "0"
      Option "SuspendTime" "0"
      Option "OffTime" "0"
      Option "BlankTime" "0"
      '';

      desktopManager = {
        xterm.enable = false;
        session = [{
          name = "WM";
          start = ''${pkgs.runtimeShell} $HOME/.xsession & waitPID=$!'';
        }];
      };

      displayManager = {
        autoLogin = {
          enable = true;
          user = "${config.autoLoginUser}";
        };

        defaultSession = "WM";

        sddm = {
          enable = true;
          theme = "custom";

          settings = {
            autoLogin = {
              Session = "WM";
              User = "${config.autoLoginUser}";
            };
            users = {
              RememberLastUser = true;
              RememberLastSession = true;
            };
          };
        };
      };
    };
  };
}
