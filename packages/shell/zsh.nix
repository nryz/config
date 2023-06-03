{ inputs, pkgs, my
, xdg
, stdenvNoCC
, variables ? {}
, editor
, wrapPackage
}:

let
  lib = pkgs.lib;
 
  zsh-vi-mode = stdenvNoCC.mkDerivation rec {
    src = inputs.zsh-vi-mode;

    pname = "zsh-vi-mode";
    version = "latest";
  
    dontBuild = true;

    installPhase = ''
      mkdir -p $out/share/zsh-vi-mode
      cp zsh-vi-mode.zsh $out/share/zsh-vi-mode
    '';

    installFlags = [ "PREFIX=$(out)" ];
  };
  
  common = import ./common.nix { 
    inherit my pkgs xdg variables editor; 
    shell = "zsh";
  };

in wrapPackage {
  pkg = pkgs.zsh;
  name = "zsh";

  outputs.extraPkgs = {
    install = true;
    files = common.pkgs;
  };
  
  vars = {
    "ZDOTDIR" = "${placeholder "out"}/config";
  };
  
  files = {
    "config/.zshrc" = ''
      typeset -U path cdpath fpath manpath

      for profile in ''${(z)NIX_PROFILES}; do
        fpath+=($profile/share/zsh/site-functions $profile/share/zsh/$ZSH_VERSION/functions $profile/share/zsh/vendor-completions)
      done

      autoload -U compinit && compinit

      source "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
      source "${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    
      HISTSIZE="10000"
      SAVEHIST="10000"
    
      HISTFILE="$XDG_STATE_HOME/zsh/history/histfile"
      mkdir -p "$(dirname "$HISTFILE")"

      setopt HIST_IGNORE_DUPS
      setopt HIST_IGNORE_SPACE
      setopt HIST_FCNTL_LOCK
      unsetopt HIST_EXPIRE_DUPS_FIRST
      setopt SHARE_HISTORY
      setopt EXTENDED_HISTORY

      HELPDIR="${pkgs.zsh}/share/zsh/$ZSH_VERSION/help"
        
      chpwd() ${pkgs.lsd}/bin/lsd
    
      # Aliases
      ${lib.concatStrings (lib.mapAttrsToList (n: v: ''
        alias ${n}='${v}'
      '') common.aliases)}


      # Prompt
      fpath+=(${inputs.zsh-pure-prompt})
    
      autoload -U promptinit; promptinit
      prompt pure
    

      ZVM_INIT_MODE=sourcing
      source ${zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.zsh

      bindkey "^[[1;5C" forward-word #ctrl-right
      bindkey "^[[1;5D" backward-word #ctrl-left

      source "${my.pkgs.skim}/share/skim/completion.zsh"
      source "${my.pkgs.skim}/share/skim/key-bindings.zsh"
  '';

    "config/.zshenv" = common.defaultVariables + ''
      ${lib.concatStrings (lib.mapAttrsToList (n: v: ''
        export ${n}="${v}"
      '') common.variables)}
    '';

    "config/.zprofile" = "";
    "config/.zlogin" = "";
    "config/.zlogout" = "";
  };
  
  extraAttrs.shellPath = "/bin/zsh";
}
