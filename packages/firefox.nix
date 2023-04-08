{ pkgs, my
, base16
, wrapPackage
}:

let
	lib = pkgs.lib;
	
	extensions = with pkgs.nur.repos.rycee.firefox-addons; [
	 	bitwarden
	 	vimium
		
	 	old-reddit-redirect
	 	reddit-enhancement-suite
		
	 	# https-everywhere
	 	ublock-origin
	 	privacy-badger
	 ];

in wrapPackage {
  pkg = pkgs.wrapFirefox pkgs.firefox-esr-unwrapped {
		extraPrefs = with base16.withHashtag; ''

			// IMPORTANT: Start your code on the 2nd line
			pref("browser.aboutwelcome.enabled", false);
			lockPref("extensions.activeThemeID", "firefox-compact-dark@mozilla.org");
			lockPref("startup.homepage_welcome_url", "");
			lockPref("app.normandy.api_url", "");
			lockPref("app.normandy.enabled", false);
			lockPref("app.shield.optoutstudies.enabled", false);
			lockPref("beacon.enabled", false);
			lockPref("browser.aboutConfig.showWarning", false);
			lockPref("browser.display.background_color", "${base00}");
			lockPref("browser.fixup.alternate.enabled", false);
			lockPref("browser.newtab.preload", false);
			lockPref("browser.newtab.url", "about:blank");
			lockPref("browser.newtabpage.activity-stream.enabled", false);
			lockPref("browser.newtabpage.directory.ping", "");
			lockPref("browser.newtabpage.directory.source", "data:text/plain,{}");
			lockPref("browser.newtabpage.enabled", false);
			lockPref("browser.newtabpage.enhanced", false);
			lockPref("browser.send_pings", false);
			lockPref("browser.shell.checkDefaultBrowser", false);
			lockPref("browser.startup.homepage", "about:blank");
			lockPref("browser.tabs.warnOnClose", true);
			lockPref("browser.urlbar.richsuggestions.tail", false);
			lockPref("browser.urlbar.suggest.engines", false);
			lockPref("browser.urlbar.suggest.history", true);
			lockPref("browser.urlbar.suggest.openpage", false);
			lockPref("browser.urlbar.suggest.searches", false);
			lockPref("browser.urlbar.suggest.topsites", false);
			lockPref("datareporting.healthreport.service.enabled", false);
			lockPref("datareporting.healthreport.uploadEnabled", false);
			lockPref("datareporting.policy.dataSubmissionEnabled", false);
			lockPref("devtools.theme", "dark");
			lockPref("experiments.enabled", false);
			lockPref("experiments.manifest.uri", "");
			lockPref("experiments.supported", false);
			lockPref("extensions.htmlaboutaddons.discover.enabled", false);
			lockPref("extensions.htmlaboutaddons.recommendations.enabled", false);
			lockPref("extensions.pocket.enabled", false);
			lockPref("extensions.shield-recipe-client.enabled", false);
			lockPref("general.smoothscroll", false);
			lockPref("identity.fxaccounts.enabled", false);
			lockPref("layers.acceleration.force-enabled", true);
			lockPref("media.videocontrols.picture-in-picture.video-toggle.enabled", false);
			lockPref("services.sync.prefs.sync.browser.urlbar.suggest.engines", false);
			lockPref("services.sync.prefs.sync.browser.urlbar.suggest.history", false);
			lockPref("services.sync.prefs.sync.browser.urlbar.suggest.openpage", false);
			lockPref("services.sync.prefs.sync.browser.urlbar.suggest.searches", false);
			lockPref("services.sync.prefs.sync.browser.urlbar.suggest.topsites", false);
			lockPref("signon.rememberSignons", false);
			lockPref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
			lockPref("toolkit.telemetry.archive.enabled", false);
			lockPref("toolkit.telemetry.enabled", false);
			lockPref("toolkit.telemetry.unified", false);
	 	'';

		nixExtensions = map (x:
			(pkgs.fetchFirefoxAddon {
        name = x.name;
        url = x.src.url;
        sha256 = x.src.outputHash; 
			})
		) extensions;
	};
  name = "firefox";
}
