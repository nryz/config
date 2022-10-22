{ inputs, pkgs, my, xdg, stdenvNoCC, ... }:

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
  
  common = import ./common.nix { inherit pkgs xdg; };
  
  zshrc = ''
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

    eval "$(${my.pkgs.direnv}/bin/direnv hook zsh)"

    source "${pkgs.fzf}/share/fzf/completion.zsh"
    source "${pkgs.fzf}/share/fzf/key-bindings.zsh"

    export FZF_DEFAULT_COMMAND="${pkgs.fd}/bin/fd --hidden --follow --exclude '.git' --exclude '.cache'"
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_CTRL_R_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND --type d"
    export FZF_DEFAULT_OPTS="--layout=reverse --info=inline --height=80% --multi --preview-window=:hidden --preview '([[ -f {} ]] && (bat --style=numbers --color=always {} || cat {})) || ([[ -d {} ]] && (tree -C {} | less)) || echo {} 2> /dev/null | head -200' --bind '?:toggle-preview'"
  '';
      
  zshenv = ''
    ${lib.concatStrings (lib.mapAttrsToList (n: v: ''
      export ${n}="${v}"
    '') common.variables)}
  '' + common.defaultVariables;

in my.lib.wrapPackage {
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
    "config/.zshrc" = zshrc;
    "config/.zshenv" = zshenv;
    "config/.zprofile" = "";
    "config/.zlogin" = "";
    "config/.zlogout" = "";
  };
  
  extraAttrs.shellPath = "/bin/zsh";
}
