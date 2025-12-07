{
  inputs = {
    self = {
      sourceInfo.filters = ["."]; # disables source filtering, i.e. allowing hidden directories
    };
    nixpkgs.url = "https://github.com/NixOS/nixpkgs/archive/refs/tags/25.05.tar.gz";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };
      kclPath = builtins.path {
        path = ./bin/kcl; # TODO: flake cannot find hidden files
        name = "kcl-local";
      };
      kclPatched = pkgs.runCommand "kcl-patched" { buildInputs = [pkgs.patchelf]; } ''
        mkdir -p $out/bin
        cp ${kclPath} $out/bin/kcl
        chmod +w $out/bin/kcl
        patchelf \
          --set-interpreter $(patchelf --print-interpreter ${pkgs.stdenv.cc.libc}) \
          --set-rpath ${pkgs.stdenv.cc.libc}/lib \
          $out/bin/kcl
      '';
    in
    {
      devShells = {
        default = pkgs.mkShell {
          buildInputs = [
            kclPatched
          ];

          shellHook = ''

          '';
        };
      };
    }
  );
}
