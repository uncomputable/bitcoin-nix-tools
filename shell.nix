{ nixpkgs ? import <nixpkgs> {}
, env ? "stdenv"
, withGui ? false
, withWallet ? true
, withTests ? true
}:
let
  main = import ./. {
    inherit nixpkgs env withGui withWallet withTests;
    doCheck = false;
  };
in
  nixpkgs.mkShell.override {
    stdenv = nixpkgs.clang14Stdenv; # requires recent version for fuzzing
  } {
    inputsFrom = [ main.bitcoin ];
  }
