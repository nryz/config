{
  inputs,
  system,
}: let
  nixpkgs = import inputs.nixpkgs {
    inherit system;

    config.allowUnfree = true;

    overlays = [
      (self: super: {
        herbstluftwm = inputs.nixpkgs-stable.legacyPackages.${system}.herbstluftwm;
      })
      inputs.nur.overlay
    ];
  };

  lib = nixpkgs.lib;
  mylib = import ../lib {inherit lib;};

  args = with mylib; rec {
    inherit inputs system;

    my.pkgs = mypkgs;
    my.lib = mylib;

    pkgs = nixpkgs;

    naersk = nixpkgs.callPackage inputs.naersk {};
    base16 = let
      attrs = builtins.fromJSON (builtins.readFile ../data/colours/rose-pine.json);
    in
      (nixpkgs.callPackage inputs.base16.lib {}).mkSchemeAttrs attrs;

    terminal = mkDefPkg mypkgs.alacritty "Alacritty.desktop";
    editor = mkDefPkg mypkgs.helix "Helix.desktop";
    browser = mkDefPkg mypkgs.qutebrowser "org.qutebrowser.qutebrowser.desktop";
    imageViewer = mkDefPkg mypkgs.imv "imv.desktop";
    videoPlayer = mkDefPkg mypkgs.imv "mpv.desktop";
    pdfViewer = mkDefPkg mypkgs.zathura "org.pwmt.zathura.desktop";

    backgrounds = ../data/backgrounds;

    cursor.package = nixpkgs.vanilla-dmz;
    cursor.name = "Vanilla-DMZ";
    cursor.size = 16;

    font.package = nixpkgs.nerdfonts.override {fonts = ["SourceCodePro"];};
    font.name = "SauceCode Pro Nerd Font";
    font.size = 9;

    xdg.cacheHome = "$HOME/.cache";
    xdg.configHome = "$HOME/.config";
    xdg.dataHome = "$HOME/.local/share";
    xdg.stateHome = "$HOME/.local/state";

    wrapPackage = args:
      mylib.wrapPackage (args
        // {
          pkgs = nixpkgs;

          share =
            [mypkgs.theme]
            ++ lib.optionals (args ? share) args.share;
          prefix =
            {"XCURSOR_PATH" = [":" "${mypkgs.theme}/share/icons"];}
            // lib.optionalAttrs (args ? prefix) args.prefix;
        });
  };

  callPackage = nixpkgs.newScope args;
  gtk = import ./gtk-functions.nix args;

  mypkgs =
    (with nixpkgs;
      gtk.wrapGtkPackages [
        blueberry
        gucharmap
        xfce.thunar
        filezilla
        gnome.nautilus
        dolphin
        lxappearance
      ])
    // {
      alacritty = callPackage ./alacritty.nix {};
      bottom = callPackage ./bottom.nix {};
      direnv = callPackage ./direnv.nix {};
      dunst = callPackage ./dunst.nix {};
      firefox = callPackage ./firefox.nix {};
      git = callPackage ./git.nix {};
      gitui = callPackage ./gitui.nix {};
      helix = callPackage ./helix.nix {};
      herbstluftwm = callPackage ./wm/herbstluftwm.nix {};
      imv = callPackage ./imv.nix {};
      joshuto = callPackage ./joshuto.nix {};
      kitty = callPackage ./kitty.nix {};
      mimeapps = callPackage ./mimeapps.nix {};
      mpv = callPackage ./mpv.nix {};
      nix-index = callPackage ./nix-index.nix {};
      picom = callPackage ./picom.nix {};
      qutebrowser = callPackage ./qutebrowser.nix {};
      rofi = callPackage ./rofi.nix {};
      startx = callPackage ./wm/startx.nix {};
      theme = callPackage ./theme.nix {};
      unclutter = callPackage ./unclutter.nix {};
      yambar = callPackage ./wm/yambar.nix {};
      zathura = callPackage ./zathura.nix {};
      zsh = callPackage ./shell/zsh.nix {};
      skim = callPackage ./skim.nix {};

      fontconfig = callPackage ./fontconfig.nix {};

      all = let
        all-pkgs =
          builtins.filter (x: lib.isDerivation x && x.name != "all")
          (lib.mapAttrsToList (n: v: v) mypkgs);
      in
        nixpkgs.linkFarmFromDrvs "all" all-pkgs;
    };
in
  mypkgs
