{
  description = "NixOS config";

  inputs = {
    #nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs.url = github:nixos/nixpkgs/nixos-unstable;

    nixpkgs-stable.url = github:nixos/nixpkgs;

    nur.url = github:nix-community/NUR;
    utils.url = github:gytis-ivaskevicius/flake-utils-plus;

    home-manager = {
      url = github:nix-community/home-manager/master;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = { url = github:nix-community/impermanence; };

    base16 = { url = github:SenchoPens/base16.nix; inputs.nixpkgs.follows = "nixpkgs"; };
    base16-vim = { url = github:chriskempson/base16-vim; flake = false; };
    base16-qutebrowser = { url = github:theova/base16-qutebrowser; flake = false; };
    base16-zathura = { url = github:haozeke/base16-zathura; flake = false; };
    base16-kakoune = { url = github:AprilArcus/base16-kakoune; flake = false; };
    base16-dunst = { url = github:khamer/base16-dunst; flake = false; };

    poly-dark-grub = { url = github:shvchk/poly-dark; flake = false; };
    sddm-wynn = { url = github:m-wynn/sddm_wynn-theme; flake = false; };

    homeage = { url = github:jordanisaacs/homeage; inputs.nixpkgs.follows = "nixpkgs"; };
    passage = { url = github:filosottile/passage; flake = false; };

    zsh-pure-prompt = { url = github:sindresorhus/pure; flake = false; };
    zsh-vi-mode = { url = github:jeffreytse/zsh-vi-mode; flake = false; };

    picom-ibhagwan = { url = github:ibhagwan/picom; flake = false; };
    sway-launcher-desktop = { url = github:Biont/sway-launcher-desktop; flake = false; };

    neovim-nightly = { 
      url = github:nix-community/neovim-nightly-overlay; 
      inputs.nixpkgs.follows = "nixpkgs"; 
    };
    which-key-nvim = { url = github:folke/which-key.nvim; flake = false; };
    fzf-lua = { url = github:ibhagwan/fzf-lua; flake = false; };
  };

  outputs = inputs @ { self, ... }: {
    nixosConfigurations = import ./setup {
      inherit inputs self;
      system = "x86_64-linux";
      stateVersion = "21.11";
      defaultUserName = "nr";
    };
  };
}
