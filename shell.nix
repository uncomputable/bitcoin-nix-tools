{ nixpkgs ? import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/057f9aecfb71c4437d2b27d3323df7f93c010b7e.tar.gz";
    sha256 = "1ndiv385w1qyb3b18vw13991fzb9wg4cl21wglk89grsfsnra41k";
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
    stdenv = nixpkgs.clang16Stdenv; # required for fuzzing; must be recent version
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
