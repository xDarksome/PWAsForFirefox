{
  inputs = {
      nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
      flake-utils.url = "github:numtide/flake-utils";
      rust-overlay.url = "github:oxalica/rust-overlay";
    };
    
  outputs = { self, nixpkgs, flake-utils, rust-overlay, ... }:
      flake-utils.lib.eachDefaultSystem (system:
        let
          overlays = [ (import rust-overlay) ];
          pkgs = import nixpkgs { inherit system overlays; };
          rustVersion = pkgs.rust-bin.stable.latest.default;
          rustPlatform = pkgs.makeRustPlatform {
            cargo = rustVersion;
            rustc = rustVersion;
          };
          myRustBuild = rustPlatform.buildRustPackage {
            pname = "firefoxpwa"; 
            version = "2.0.3";
            src = ./.;

            nativeBuildInputs = with pkgs; [
                pkg-config
            ];

            buildInputs = with pkgs; [
                openssl.dev
            ];

            cargoLock.lockFile = ./Cargo.lock;
            cargoLock.outputHashes = {
              "data-url-0.1.0" = "sha256-rESQz5jjNpVfIuTaRCAV2TLeUs09lOaLZVACsb/3Adg=";
              "mime-0.4.0-a.0" = "sha256-LjM7LH6rL3moCKxVsA+RUL9lfnvY31IrqHa9pDIAZNE=";
              "web_app_manifest-0.0.0" = "sha256-4tPeJkxphp7Bxn4GKOMZrGQyF6xIIGCNKJ4VGFbHGFk=";
            };
          };
        in {
          defaultPackage = myRustBuild;
          devShell = pkgs.mkShell {
            buildInputs =
              [ (rustVersion.override { extensions = [ "rust-src" ]; }) ];
          };
        });
}