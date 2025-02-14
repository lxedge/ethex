{
  description = "Nita OS Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=master";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        LANG = "C.UTF-8";
      in
      with pkgs; {
        devShells.default = mkShell {
          inherit LANG;

          buildInputs = [
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
          '';
        };
      }
    );
}
