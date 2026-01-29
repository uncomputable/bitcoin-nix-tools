{ nixpkgs ? import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/871b9fd269ff6246794583ce4ee1031e1da71895.tar.gz";
    sha256 = "1zn1lsafn62sz6azx6j735fh4vwwghj8cc9x91g5sx2nrg23ap9k";
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
    stdenv = nixpkgs.clang19Stdenv; # required for fuzzing; must be recent version
  } {
    inherit (main.bitcoin) configureFlags;
    inputsFrom = [
      main.bitcoin
    ];
    buildInputs = with nixpkgs; [
      libllvm
      lcov
      cmake
      capnproto
    ];
  }
