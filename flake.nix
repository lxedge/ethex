{
  description = "Ethex Flake";

  inputs = {
    rust-overlay.url = "github:oxalica/rust-overlay";
    nixpkgs.url = "github:NixOS/nixpkgs?ref=master";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
        LANG = "C.UTF-8";
      in
      with pkgs; {
        devShells.default = mkShell {
          inherit LANG;

          buildInputs = [
            (rust-bin.stable.latest.default.override {
              extensions = [ "rust-src" "rust-analyzer" ];
            })
	    rust-analyzer
	    pkg-config
            openssl
            cargo
            binaryen
            just
            zellij
            curl
            jq
            unzip
            nodejs_22
            erlang_26
            beam.packages.erlang_26.elixir_1_18
          ]
          ++ lib.optionals stdenv.isLinux [
            libnotify
            inotify-tools
          ]
          ++ lib.optionals stdenv.isDarwin ([
            terminal-notifier
            darwin.apple_sdk.frameworks.CoreFoundation
            darwin.apple_sdk.frameworks.CoreServices
          ]);

          shellHook = ''
            # allows mix to work on the local directory
            mkdir -p .nix-mix .nix-hex

            export MIX_HOME=$PWD/.nix-mix
            export HEX_HOME=$PWD/.nix-hex
            export ERL_LIBS=$HEX_HOME/lib/erlang/lib
            export PATH=$MIX_HOME/bin:$PATH
            export PATH=$MIX_HOME/escripts:$PATH
            export PATH=$HEX_HOME/bin:$PATH
            export ERL_AFLAGS="-kernel shell_history enabled -kernel shell_history_path '\"$PWD/.erlang-history\"'"
            export ELIXIR_ERL_OPTIONS="+fnu"
            # export HEX_MIRROR=https://hexpm.upyun.com
	    # export RUSTLER_NIF_VERSION=2.16
          '';
        };
      }
    );
}
