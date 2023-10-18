{ nixpkgs ? import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/4ecab3273592f27479a583fb6d975d4aba3486fe.tar.gz";
    sha256 = "10wn0l08j9lgqcw8177nh2ljrnxdrpri7bp0g7nvrsn9rkawvlbf";
  }) {}
, withGui ? false
, withWallet ? true
, withTests ? true
}:
let
  main = import ./. {
    inherit nixpkgs withGui withWallet withTests;
    doCheck = false;
  };
in
  nixpkgs.mkShell.override {
    stdenv = nixpkgs.clang16Stdenv; # requires recent version for fuzzing
  } {
    inherit (main.bitcoin) configureFlags;
    inputsFrom = [ main.bitcoin ];
  }
