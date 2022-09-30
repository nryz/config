{ 
  stdenvNoCC, 
  src, 
  conf ? ""
}:

stdenvNoCC.mkDerivation rec {
  inherit src;

  pname = "zsh-vi-mode";
  version = "latest";
  
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/zsh-vi-mode
    cp zsh-vi-mode.zsh $out/share/zsh-vi-mode
  '';

  installFlags = [ "PREFIX=$(out)" ];
}
