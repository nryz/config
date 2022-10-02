{ config, pkgs, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.blocks.programs.firefox;
in
{
  options.blocks.programs.firefox = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    blocks.persist.userDirectories = [ ".mozilla/firefox/default" ];

    hm.programs.firefox = {
      enable = true;

      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        bitwarden
        tree-style-tab
        vimium

        old-reddit-redirect
        reddit-enhancement-suite

        https-everywhere
        ublock-origin
        privacy-badger
      ];

      profiles.default = {
        isDefault = true;

        name = "default";
        path = "default";

        userChrome = with config.scheme.withHashtag; ''
          /* hides the native tabs*/
          #TabsToolbar {
            visibility: collapse !important;
          }

          #titlebar {
            visibility: collapse !important;
          }

          :root{
            --theme-colors-sidebar: ${base00} !important;
            --theme-colors-side_text: ${base05} !important;

            /* Popup panels */
            --arrowpanel-background: ${base00} !important;
            --arrowpanel-border-color: ${base01} !important;
            --arrowpanel-color: ${base05} !important;
            --arrowpanel-dimmed: rgba(0,0,0,0.4) !important;
            /* window and toolbar background */
            --lwt-accent-color: ${base05} !important;
            --toolbar-bgcolor: ${base00} !important;
            /* tabs */
            --lwt-text-color: ${base05} !important;
            /* toolbar area */
            --toolbarbutton-icon-fill: ${base05} !important;
            --lwt-toolbarbutton-hover-background: ${base01} !important;
            --lwt-toolbarbutton-active-background: ${base01} !important;
            --button-hover-bgcolor: ${base01} !important;
            /* urlbar */
            --toolbar-field-border-color: ${base01} !important;
            --toolbar-field-focus-border-color: ${base01} !important;
            --urlbar-popup-url-color: ${base0B} !important;
            --autocomplete-popup-highlight-background: ${base00} !important;
            --autocomplete-popup-hover-background: ${base00} !important;
            /* urlbar Firefox < 92 */
            --lwt-toolbar-field-background-color: ${base00} !important;
            --lwt-toolbar-field-focus: ${base00} !important;
            --lwt-toolbar-field-color: ${base05} !important;
            --lwt-toolbar-field-focus-color: ${base05} !important;
            /* urlbar Firefox 92+ */
            --toolbar-field-background-color: ${base00} !important;
            --toolbar-field-focus-background-color: ${base01} !important;
            --toolbar-field-color: ${base05} !important;
            --toolbar-field-focus-color: ${base05} !important;
            /* sidebar - note the sidebar-box rule for the header-area */
            --lwt-sidebar-background-color: ${base00} !important;
            --lwt-sidebar-text-color: ${base05} !important;
          }

          /*
          #nav-bar {
            height: 24px !important;
          }

          #nav-bar .toolbarbutton-1:not([type="menu-button"]), 
          #nav-bar .toolbarbutton-1 > .toolbarbutton-menubutton-button, 
          #nav-bar .toolbarbutton-1 > .toolbarbutton-menubutton-dropmarker {
            padding: 0 !important; 
          }
          */

          /* Line above tabs */
          #tabbrowser-tabs{ --tab-line-color: ${base00} !important; }
          /* the header-area of sidebar needs this to work */
          #sidebar-box{ --sidebar-background-color: ${base00} !important; }


          #sidebar-box[sidebarcommand="treestyletab_piro_sakura_ne_jp-sidebar-action"] #sidebar-header {
            display: none;
          }
        '';

        userContent = ''
        '';

        settings = with config.scheme.withHashtag; {
          "browser.urlbar.suggest.history" = true;
          "general.smoothscroll" = false;
          "layers.acceleration.force-enabled" = true;
          "browser.aboutConfig.showWarning" = false;
          "browser.tabs.warnOnClose" = true;

          "devtools.theme" = "dark";
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          "signon.rememberSignons" = false;
          "browser.shell.checkDefaultBrowser" = false;
          "browser.newtabpage.activity-stream.enabled" = false;

          "identity.fxaccounts.enabled" = false;

          #url suggestions and stuff
          "browser.urlbar.richsuggestions.tail" = false;
          "browser.urlbar.suggest.engines" = false;
          "browser.urlbar.suggest.openpage" = false;
          "browser.urlbar.suggest.searches" = false;
          "browser.urlbar.suggest.topsites" = false;
          #don't actually know what these are?
          "services.sync.prefs.sync.browser.urlbar.suggest.engines" = false;
          "services.sync.prefs.sync.browser.urlbar.suggest.history" = false;
          "services.sync.prefs.sync.browser.urlbar.suggest.openpage" = false;
          "services.sync.prefs.sync.browser.urlbar.suggest.searches" = false;
          "services.sync.prefs.sync.browser.urlbar.suggest.topsites" = false;

          #New tab stuff
          "browser.newtabpage.enabled" = false;
          "browser.newtab.url" = "about:blank";
          "browser.display.background_color" = "${base00}";
          "browser.newtabpage.enhanced" = false;
          "browser.newtab.preload" = false;
          "browser.newtabpage.directory.ping" = "";
          "browser.newtabpage.directory.source" = "data:text/plain,{}";
          "browser.startup.homepage" = "about:blank";

          #Disable some not so useful functionality.
          "media.videocontrols.picture-in-picture.video-toggle.enabled" = false;
          "extensions.htmlaboutaddons.recommendations.enabled" = false;
          "extensions.htmlaboutaddons.discover.enabled" = false;
          "extensions.pocket.enabled" = false;
          "app.normandy.enabled" = false;
          "app.normandy.api_url" = "";
          "extensions.shield-recipe-client.enabled" = false;
          "app.shield.optoutstudies.enabled" = false;

          "beacon.enabled" = false;
          "browser.send_pings" = false;
          "browser.fixup.alternate.enabled" = false;

          #Disable telemetry
          "toolkit.telemetry.enabled" = false;
          "toolkit.telemetry.unified" = false;
          "toolkit.telemetry.archive.enabled" = false;
          "experiments.supported" = false;
          "experiments.enabled" = false;
          "experiments.manifest.uri" = "";
          "datareporting.healthreport.uploadEnabled" = false;
          "datareporting.healthreport.service.enabled" = false;
          "datareporting.policy.dataSubmissionEnabled" = false;
        };
      };
    };
  };
}
