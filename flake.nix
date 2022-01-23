{
description = "NixOS config";

inputs = {
  nixpkgs.url = "nixpkgs/nixos-unstable";
  nur.url = github:nix-community/NUR;
  utils.url = github:gytis-ivaskevicius/flake-utils-plus;

  home-manager = {
    url = github:nix-community/home-manager/master;
    inputs.nixpkgs.follows = "nixpkgs";
  };

  base16 = { url = github:SenchoPens/base16.nix; inputs.nixpkgs.follows = "nixpkgs"; };
  base16Theme = { url = github:dawikur/base16-gruvbox-scheme; flake = false; };
  base16-vim = { url = github:chriskempson/base16-vim; flake = false; };
  base16-kitty = { url = github:kdrag0n/base16-kitty; flake = false; };
  base16-qutebrowser = { url = github:theova/base16-qutebrowser; flake = false; };
  base16-zathura = { url = github:haozeke/base16-zathura; flake = false; };
  base16-kakoune = { url = github:AprilArcus/base16-kakoune; flake = false; };
  base16-dunst = { url = github:khamer/base16-dunst; flake = false; };

  poly-dark-grub = { url = github:shvchk/poly-dark; flake = false; };
  sddm-wynn = { url = github:m-wynn/sddm_wynn-theme; flake = false; };

  zsh-vi-mode = { url = github:jeffreytse/zsh-vi-mode; flake = false; };

  homeage = { url = github:jordanisaacs/homeage; inputs.nixpkgs.follows = "nixpkgs"; };

  impermanence = { url = github:nix-community/impermanence?ref=nixos-users; };

  passage = { url = github:filosottile/passage; flake = false; };

  zsh-pure-prompt = { url = github:sindresorhus/pure; flake = false; };
  picom-ibhagwan = { url = github:ibhagwan/picom; flake = false; };
  sway-launcher-desktop = { url = github:Biont/sway-launcher-desktop; flake = false; };

  neovim-nightly.url = github:nix-community/neovim-nightly-overlay;
  which-key-nvim = { url = github:folke/which-key.nvim; flake = false; };
  fzf-lua = { url = github:ibhagwan/fzf-lua; flake = false; };
};

outputs = inputs @ { self, utils, nixpkgs, ... }: let
  inherit (lib.my) mkNixoses collectBlocks;

  lib = import ./lib { inherit inputs; };
in {
  nixosConfigurations = mkNixoses ./config/hosts rec {
    system = "x86_64-linux";
    stateVersion = "21.11";

    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;

      overlays = [

        (final: prev: { 
          poly-dark-grub = inputs.poly-dark-grub;
          sddm-theme = prev.callPackage ./pkgs/sddm-theme { src = inputs.sddm-wynn; };

          passage = prev.callPackage ./pkgs/passage { src = inputs.passage; };

          zsh-vi-mode = prev.callPackage ./pkgs/zsh-vi-mode { src = inputs.zsh-vi-mode; };

          sway-launcher-desktop = prev.writeShellScriptBin "sway-launcher-desktop"
          (builtins.readFile "${inputs.sway-launcher-desktop}/sway-launcher-desktop.sh");

          zsh-pure-prompt = {
            name = "pure-prompt";
            src = inputs.zsh-pure-prompt;
            file = "pure.zsh";
          };

          vimPlugins = prev.vimPlugins // {
            which-key-nvim = prev.vimUtils.buildVimPlugin {
              name = "which-key-nvim";
              src = inputs.which-key-nvim;
            };
            fzf-lua = prev.vimUtils.buildVimPlugin {
              name = "fzf-lua";
              src = inputs.fzf-lua;
            };
          };

          picom-ibhagwan = prev.picom.overrideAttrs(o: { src = inputs.picom-ibhagwan; });
        })

        inputs.nur.overlay
        inputs.neovim-nightly.overlay
        inputs.utils.overlay

      ];
    };

    systemBlocks = collectBlocks ./blocks/system;
    homeBlocks = collectBlocks ./blocks/home;
  };
};}
