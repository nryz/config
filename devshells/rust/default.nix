{
  lib,
  pkgs,
  ...
}:
pkgs.mkShell {
  buildInputs = with pkgs; [cargo rustc rustfmt pre-commit rustPackages.clippy rust-analyzer];
  RUST_SRC_PATH = pkgs.rustPlatform.rustLibSrc;
}
