{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: {
    devShells =
      nixpkgs.lib.genAttrs [
        "x86_64-linux"
      ] (
        system: let
          pkgs = import nixpkgs {inherit system;};
        in {
          default = with pkgs;
            mkShell {
              buildInputs = [
                cargo
                rustc
                rustfmt
                rustPackages.clippy
                rust-analyzer
              ];
              RUST_SRC_PATH = rustPlatform.rustLibSrc;
            };
        }
      );
  };
}
