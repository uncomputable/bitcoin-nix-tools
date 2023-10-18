{ nixpkgs ? import builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/4ecab3273592f27479a583fb6d975d4aba3486fe.tar.gz";
    sha256 = "10wn0l08j9lgqcw8177nh2ljrnxdrpri7bp0g7nvrsn9rkawvlbf";
  } {}
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
