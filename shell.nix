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
  nixpkgs.mkShell {
    inputsFrom = [ main.bitcoin ];
  }
