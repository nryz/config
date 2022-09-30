{ config, lib, pkgs, extraPkgs, ... }:

with lib;
with lib.my;
let 
  cfg = config.blocks.programs.zsh;
in
{
  options.blocks.programs.zsh = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    #blocks.persist.files = [ ".zsh_history" ];

    programs.zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableCompletion = true;
      enableSyntaxHighlighting = true;
      history.extended = true;
      history.path = "$HOME/.zsh/history";

      plugins = with extraPkgs; [
        zsh-pure-prompt
      ];
      
      initExtra = ''
        ZVM_INIT_MODE=sourcing
        source ${extraPkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.zsh

        #KEYTIMEOUT=1

        bindkey "^[[1;5C" forward-word #ctrl-right
        bindkey "^[[1;5D" backward-word #ctrl-left

        chpwd() lsd

        source "''$(fzf-share)/key-bindings.zsh"
        source "''$(fzf-share)/completion.zsh"

        export FZF_DEFAULT_COMMAND="fd --hidden --follow --exclude '.git' --exclude '.cache'"
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND --type d"
        export FZF_DEFAULT_OPTS="--layout=reverse --info=inline --height=80% --multi --preview-window=:hidden --preview '([[ -f {} ]] && (bat --style=numbers --color=always {} || cat {})) || ([[ -d {} ]] && (tree -C {} | less)) || echo {} 2> /dev/null | head -200' --bind '?:toggle-preview'"
      '';
    };
  };
}
