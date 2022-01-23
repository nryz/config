{ stdenv, gnumake, makeWrapper, src, postInstall ? "" }:

stdenv.mkDerivation rec {
  inherit src postInstall;

  pname = "passage";
  version = "latest";

  nativeBuildInputs = [ gnumake ];

  buildInputs = [ makeWrapper ];

  installPhase = ''
    PREFIX=$out make install

    runHook postInstall
  '';
}


