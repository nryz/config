{ 
  stdenv, 
  src, 
  conf ? ""
}:

stdenv.mkDerivation rec {
  inherit src;

  pname = "sddm-theme";
  version = "latest";

  installPhase = ''
    mkdir -p $out/share/sddm/themes/custom
    mv * $out/share/sddm/themes/custom/
    echo "${conf}" > $out/share/sddm/themes/custom/theme.conf.user
  '';
}
