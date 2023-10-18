{ nixpkgs ? import <nixpkgs> {}
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
    stdenv = nixpkgs.clang14Stdenv; # requires recent version for fuzzing
  } {
    inputsFrom = [ main.bitcoin ];
  }
