{
  inputs = {
    naersk.url = "github:nix-community/naersk/master";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils, naersk }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        naersk-lib = pkgs.callPackage naersk { };
      in
      {
        nativeBuildInputs = with pkgs; [ freetype pkg-config cmake ];
        defaultPackage = naersk-lib.buildPackage {
          src = ./.;
          # buildInputs = with pkgs; [ gccStdenv cmake ];
          # nativeBuildInputs = with pkgs; [ gccStdenv cmake ];
        };
        devShell = with pkgs; mkShell rec {
          nativeBuildInputs = [ freetype pkg-config cmake wayland libGL libxkbcommon ];
          buildInputs = [ cargo rustc rustfmt pre-commit rustPackages.clippy wayland libGL libxkbcommon ];
          RUST_SRC_PATH = rustPlatform.rustLibSrc;
          LD_LIBRARY_PATH = "${lib.makeLibraryPath buildInputs}";
        };
      }
    );
}
