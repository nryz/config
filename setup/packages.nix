{ inputs, system }: rec {
  pkgs = import inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;

    overlays = [
      inputs.nur.overlay
      inputs.neovim-nightly.overlay
      inputs.utils.overlay
    ];
  };

  stablePkgs = import inputs.nixpkgs-stable {
    inherit system;
    config.allowUnfree = true;
  };

  extraPkgs = {
    poly-dark-grub = inputs.poly-dark-grub;

    zsh-pure-prompt = {
      name = "pure-prompt";
      src = inputs.zsh-pure-prompt;
      file = "pure.zsh";
    };

    sddm-theme = pkgs.callPackage ../pkgs/sddm-theme { src = inputs.sddm-wynn; };
    passage = pkgs.callPackage ../pkgs/passage { src = inputs.passage; };
    zsh-vi-mode = pkgs.callPackage ../pkgs/zsh-vi-mode { src = inputs.zsh-vi-mode; };

    swhkd = pkgs.callPackage ../pkgs/swhkd { };

    sway-launcher-desktop = pkgs.writeShellScriptBin "sway-launcher-desktop"
      (builtins.readFile "${inputs.sway-launcher-desktop}/sway-launcher-desktop.sh");

    vimPlugins = pkgs.vimPlugins // {
      which-key-nvim = pkgs.vimUtils.buildVimPlugin {
        name = "which-key-nvim";
        src = inputs.which-key-nvim;
      };
      fzf-lua = pkgs.vimUtils.buildVimPlugin {
        name = "fzf-lua";
        src = inputs.fzf-lua;
      };
    };

    picom-ibhagwan = pkgs.picom.overrideAttrs(o: { src = inputs.picom-ibhagwan; });
  };
}
