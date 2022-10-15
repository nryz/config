{ inputs, pkgs, my, ... }:

let
  lib = pkgs.lib;
 
  # todo
  # XCURSOR_PATH="$XCURSOR_PATH${XCURSOR_PATH:+:}/etc/profiles/per-user/nr/share/icons";
  
  # do I need to set ?
  # export XDG_CACHE_HOME="/home/hm-user/.cache"
  # export XDG_CONFIG_HOME="/home/hm-user/.config"
  # export XDG_DATA_HOME="/home/hm-user/.local/share"
  # export XDG_STATE_HOME="/home/hm-user/.local/state"
  
  common = import ./common.nix { inherit pkgs; };
  
  fzfrc = ''
    source "${pkgs.fzf}/share/fzf/completion.zsh"
    source "${pkgs.fzf}/share/fzf/key-bindings.zsh"

    export FZF_DEFAULT_COMMAND="fd --hidden --follow --exclude '.git' --exclude '.cache'"
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_CTRL_R_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND --type d"
    export FZF_DEFAULT_OPTS="--layout=reverse --info=inline --height=80% --multi --preview-window=:hidden --preview '([[ -f {} ]] && (bat --style=numbers --color=always {} || cat {})) || ([[ -d {} ]] && (tree -C {} | less)) || echo {} 2> /dev/null | head -200' --bind '?:toggle-preview'"
  '';
  
  zshvmrc = ''
    ZVM_INIT_MODE=sourcing
    source ${my.pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.zsh
  '';
  
  zshpromptrc = ''
    fpath+=(${inputs.zsh-pure-prompt})
    
    autoload -U promptinit; promptinit
    prompt pure
  '';
  
  direnvrc = ''
    source "${pkgs.nix-direnv}/share/nix-direnv/direnvrc"
  '';
  
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
        
    bindkey "^[[1;5C" forward-word #ctrl-right
    bindkey "^[[1;5D" backward-word #ctrl-left

    chpwd() lsd
    
    # Aliases
    ${lib.concatStrings (lib.mapAttrsToList (n: v: ''
      alias ${n}='${v}'
    '') common.aliases)}

  ''  + zshvmrc
      + zshpromptrc
      + fzfrc 
      + direnvrc;
      
  zshenv = ''
    ${lib.concatStrings (lib.mapAttrsToList (n: v: ''
      export ${n}="${v}"
    '') common.variables)}
    
     export LOCALE_ARCHIVE_2_27="${pkgs.glibcLocales}/lib/locale/locale-archive"
  '';

in my.lib.wrapPackageJoin {
  pkg = pkgs.zsh;
  name = "zsh";
  
  vars = {
    "ZDOTDIR" = "${placeholder "out"}/config";
  };
  
  files = {
    "config/.zshrc" = pkgs.writeText "zshrc" zshrc;
    "config/.zshenv" = pkgs.writeText "zshenv" zshenv;
    "config/.zprofile" = pkgs.emptyFile;
    "config/.zlogin" = pkgs.emptyFile;
    "config/.zlogout" = pkgs.emptyFile;
  };
}
