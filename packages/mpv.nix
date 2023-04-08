{ pkgs, my
, wrapPackage
, inputs
}:

let
  lib = pkgs.lib;

  yt-dlp = pkgs.yt-dlp.overrideAttrs(_: { src = inputs.yt-dlp; });

  scripts = with pkgs.mpvScripts; [
    mpv-playlistmanager
    
    #TODO: these don't work currently fix 
    #sponsorblock
    #youtube-quality
  ];

  luaEnv = pkgs.mpv-unwrapped.luaEnv;
  luaVersion = pkgs.mpv-unwrapped.lua.luaversion;
  
in wrapPackage {
  pkg = pkgs.mpv;
  name = "mpv";
  
  path = [
    luaEnv
    yt-dlp
  ];
  
  prefix = {
    "LUA_CPATH" = [ ";" "${luaEnv}/lib/lua/${luaVersion}/?.so" ];
    "LUA_PATH" = [";" "${luaEnv}/share/lua/${luaVersion}/?.lua" ];
  };

  vars = { 
    "MPV_HOME" = "${placeholder "out"}/config";
  };
  
  
  files = builtins.listToAttrs (map (x:  { 
    name = "config/scripts/${x.scriptName}"; 
    value = "${x}/share/mpv/scripts/${x.scriptName}";
  } ) scripts) // {

    "config/mpv.conf" = ''
      keepaspect-window=no
      keepaspect=yes
      alang=Japanese,jpn,ja,English,eng,en
      slang=English,eng,en
      pulse-latency-hacks=yes
      script-opts=ytdl_hook-ytdl_path=${yt-dlp}/bin/yt-dlp
    '';
    
    "config/input.conf" = ''
      n add chapter +1
      p add chapter -1
    '';
  };
}