{
  inputs,
  pkgs,
  my,
  xdg,
  stdenvNoCC,
  env ? {},
  editor,
  wrapPackage,
}: let
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

    installFlags = ["PREFIX=$(out)"];
  };

  common-env = import ./env.nix {
    inherit my pkgs xdg editor;
  };
in
  wrapPackage {
    pkg = pkgs.zsh;
    name = "zsh";

    extraPkgs = [my.pkgs.skim];

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

        # Aliases
        alias lsd="${pkgs.lsd}/bin/lsd --group-directories-first -1"
        alias rg="${pkgs.ripgrep}/bin/rg --no-messages"
        alias tree="tree --dirsfirst"
        alias lsb="lsblk -o name,label,type,size,rm,model,serial"


        # Prompt
        fpath+=(${inputs.zsh-pure-prompt})

        autoload -U promptinit; promptinit
        prompt pure


        ZVM_INIT_MODE=sourcing
        source ${zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.zsh

        bindkey "^[[1;5C" forward-word #ctrl-right
        bindkey "^[[1;5D" backward-word #ctrl-left

        export SKIM_DEFAULT_COMMAND="git ls-files -oc || find ."
        export SKIM_CTRL_T_COMMAND="git ls-files -oc || find ."
        source "${my.pkgs.skim}/share/skim/completion.zsh"
        source "${my.pkgs.skim}/share/skim/key-bindings.zsh"
      '';

      "config/.zshenv" = ''
        ${lib.concatStrings (lib.mapAttrsToList (n: v: ''
            export ${n}="${v}"
          '')
          common-env)}

        ${lib.concatStrings (lib.mapAttrsToList (n: v: ''
            export ${n}="${v}"
          '')
          env)}
      '';

      "config/.zprofile" = "";
      "config/.zlogin" = "";
      "config/.zlogout" = "";
    };

    extraAttrs.shellPath = "/bin/zsh";
  }
