{ inputs, system }: rec {
  pkgs = import inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;

    overlays = [
      inputs.nur.overlay
      inputs.utils.overlay
    ];
  };

  pkgsStable = import inputs.nixpkgs-stable {
    inherit system;
    config.allowUnfree = true;
  };

  extraPkgs = {
    xremap = inputs.xremap.packages.${system}.default;

    helix = inputs.helix.packages.${system};
    
    zsh-pure-prompt = {
      name = "pure-prompt";
      src = inputs.zsh-pure-prompt;
      file = "pure.zsh";
    };

    zsh-vi-mode = pkgs.callPackage ../pkgs/zsh-vi-mode { src = inputs.zsh-vi-mode; };

    sway-launcher-desktop = pkgs.writeShellScriptBin "sway-launcher-desktop"
      (builtins.readFile "${inputs.sway-launcher-desktop}/sway-launcher-desktop.sh");

    picom-ibhagwan = pkgs.picom.overrideAttrs(o: { src = inputs.picom-ibhagwan; });
  };
}
