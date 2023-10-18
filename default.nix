{ nixpkgs ? import <nixpkgs> {}
, env ? "stdenv"
, withGui ? false
, withWallet ? true
, withTests ? true
, doCheck ? true
}:
{
  bitcoin = with nixpkgs; callPackage ./bitcoin.nix {
    stdenv = clang14Stdenv;
    qtbase = qt5.qtbase;
    qttools = qt5.qttools;
    wrapQtAppsHook = qt5.wrapQtAppsHook;
    autoSignDarwinBinariesHook = darwin.autoSignDarwinBinariesHook;
    python3 = python3.withPackages (p: with p; [
      pyzmq
    ]);
  };
}
