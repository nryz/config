{
  pkgs,
  my,
  wrapPackage,
  inputs,
}: let
  lib = pkgs.lib;

  yt-dlp = pkgs.yt-dlp.overrideAttrs (_: {src = inputs.yt-dlp;});

  luaEnv = pkgs.mpv-unwrapped.luaEnv;
  luaVersion = pkgs.mpv-unwrapped.lua.luaversion;

  quality-menu = pkgs.fetchFromGitHub {
    owner = "christoph-heinrich";
    repo = "mpv-quality-menu";

    rev = "9bb4d87681b9765a8035158c9076f4a37b6f7b07";
    sha256 = "sha256-93WoTeX61xzbjx/tgBgUVuwyR9MkAUzCfVSrbAC7Ddc=";
  };
in
  wrapPackage {
    pkg = pkgs.mpv;
    name = "mpv";

    binPath = [
      luaEnv
      yt-dlp
    ];

    paths = {
      "LUA_CPATH,;" = ["${luaEnv}/lib/lua/${luaVersion}/?.so"];
      "LUA_PATH,;" = ["${luaEnv}/share/lua/${luaVersion}/?.lua"];
    };

    vars = {
      "MPV_HOME" = "${placeholder "out"}/config";
    };

    links = with pkgs.mpvScripts; {
      "config/scripts/${sponsorblock.scriptName}" = "${sponsorblock}/share/mpv/scripts/${sponsorblock.scriptName}";

      "config/scripts/quality-menu.lua" = "${quality-menu}/quality-menu.lua";
    };

    files = {
      "config/script-opts/quality-menu.conf" = ''
        fetch_on_start=no
      '';
      
      "config/mpv.conf" =
        #conf
        ''
          keepaspect-window=no
          keepaspect=yes
          alang=Japanese,jpn,ja,English,eng,en
          slang=English,eng,Eng,en,En
          pulse-latency-hacks=yes

          script-opts=ytdl_hook-ytdl_path=${yt-dlp}/bin/yt-dlp
          ytdl-format=bestvideo[height<=?2560]+bestaudio/best
        '';

      "config/input.conf" =
        #conf
        ''
          n add chapter +1
          p add chapter -1

          F     script-binding quality_menu/video_formats_toggle
          Alt+f script-binding quality_menu/audio_formats_toggle
          Ctrl+r script-binding quality_menu/reload
        '';
    };
  }
