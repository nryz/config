{ config, lib, pkgs, inputs, ... }:

with lib;
with lib.my;
let
  cfg = config.blocks.programs.qutebrowser;
in
{
  options.blocks.programs.qutebrowser = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {

    home.packages = with pkgs; [
      qt5.qtwayland
    ];

    blocks.persist.directories = [ 
      ".local/share/qutebrowser" 
    ];

    programs.qutebrowser = {
      enable = true;
      loadAutoconfig = false;

      quickmarks = {
         nixpkgs = "https://github.com/NixOS/nixpkgs";
         home-manager = "https://github.com/nix-community/home-manager";
         nixOptions = "search.nixos.org/options";
         nixPkgs = "search.nixos.org/packages";
         nixpkgsSearch = "search.nix.gsc.io/";
         nixMan = "nixos.org/manual/nix/unstable/";
         nixpkgMan = "nixos.org/manual/nixpkgs/unstable/";
         libgen = "libgen.li";
         scihub = "sci-hub-links.com/";
         z-lib = "booksc.org/";
      };

      searchEngines = {
        DEFAULT = "https://google.com/search?q={}";
        ddg = "https://duckduckgo.com/?q={}";
        r = "https://reddit.com/r/{}";
        n = "https://search.nix.gsc.io/?q={}";
        hm = "https://github.com/nix-community/home-manager/search?q={}";
        qt = "https://github.com/qtile/qtile/search?q={}";
      };

      keyBindings = {
        normal = {
          ",m" = "hint links spawn mpv {hint-url} --title='youtube' --pause --no-sub-visibility --ytdl-format=bestvideo[height<=?1080]+bestaudio/best";
          ",M" = "spawn mpv {url} --title='youtube' --pause --no-sub-visibility --ytdl-format=bestvideo[height<=?1080]+bestaudio/best";
          ";m" = "hint --rapid links spawn umpv {hint-url} --title='youtube' --pause --no-sub-visibility";
          #no point in my most used commands being behind a ctrl keymap
          "d"  = "scroll-page 0 0.5";
          "u"  = "scroll-page 0 -0.5";
        };
      };

      settings = {
        fonts = {
          default_family = "${toString config.blocks.desktop.font.size}pt ${config.blocks.desktop.font.name}";
        };
        
        scrolling.bar = "never";
        statusbar.show = "always";
        downloads.position = "bottom";
        editor.command = ["hx" "-f" "{file}" "-c" "normal {line}G{column0}l"];
        auto_save.session = true;
        completion.scrollbar.width = 0;

        url = {
          default_page = "about:blank";
          start_pages = "about:blank";
        };

        tabs = {
          position = "bottom";
          show = "never";
        };

        colors.webpage = {
          bg = "${config.scheme.withHashtag.base00}";
          darkmode.enabled = false;
        };

        content = {
          autoplay = false;
          blocking.enabled = true;
          blocking.method = "auto";

          notifications.enabled = false;

          # List of URLs to ABP-style adblocking rulesets.  Only used when Brave's
          # ABP-style adblocker is used (see `content.blocking.method`).  You can
          # find an overview of available lists here:
          # https://adblockplus.org/en/subscriptions - note that the special
          # `subscribe.adblockplus.org` links aren't handled by qutebrowser, you
          # will instead need to find the link to the raw `.txt` file (e.g. by
          # extracting it from the `location` parameter of the subscribe URL and
          # URL-decoding it).
          blocking.adblock.lists = [
            "https://pgl.yoyo.org/as/serverlist.php?hostformat=hosts;showintro=0"
            "https://easylist-downloads.adblockplus.org/easylistdutch.txt"
            "https://easylist-downloads.adblockplus.org/abp-filters-anti-cv.txt"
            "https://www.i-dont-care-about-cookies.eu/abp/"
            "https://secure.fanboy.co.nz/fanboy-cookiemonster.txt"
            "https://easylist-downloads.adblockplus.org/easylist.txt"
            "https://easylist-downloads.adblockplus.org/abp-filters-anti-cv.txt"
            "https://easylist-downloads.adblockplus.org/fanboy-notifications.txt"
            "https://easylist-downloads.adblockplus.org/easyprivacy.txt"
            "https://easylist-downloads.adblockplus.org/fanboy-social.txt"
          ];
        };
      };

      extraConfig = builtins.readFile (config.scheme inputs.base16-qutebrowser) + ''
      '' ;
    };
  };
}
