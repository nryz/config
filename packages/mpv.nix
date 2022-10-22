{ pkgs, my, wrapPackage, ... }:

let
  lib = pkgs.lib;

  scripts = with pkgs.mpvScripts; [
    mpv-playlistmanager
    
    #TODO: these don't work currently fix 
    #sponsorblock
    #youtube-quality
  ];

 configFile = ''
    keepaspect-window=no
    keepaspect=yes
    alang=Japanese,jpn,ja,English,eng,en
    slang=English,eng,en
    script-opts=ytdl_hook-ytdl_path=${pkgs.yt-dlp}/bin/yt-dlp
  '';

  luaEnv = pkgs.mpv-unwrapped.luaEnv;
  luaVersion = pkgs.mpv-unwrapped.lua.luaversion;
  
in wrapPackage {
  pkg = pkgs.mpv;
  name = "mpv";
  
  path = [
    luaEnv
    pkgs.yt-dlp
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
    "config/mpv.conf" = configFile;
  };
}