{ nixpkgs ? import builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/057f9aecfb71c4437d2b27d3323df7f93c010b7e.tar.gz";
    sha256 = "1ndiv385w1qyb3b18vw13991fzb9wg4cl21wglk89grsfsnra41k";
  } {}
, withGui ? false
, withWallet ? true
, withTests ? true
, doCheck ? true
}:
{
  bitcoin = with nixpkgs; callPackage ./bitcoin.nix {
    stdenv = clang16Stdenv;
    inherit (qt5) qtbase qttools wrapQtAppsHook;
    inherit (darwin) autoSignDarwinBinariesHook;
    python3 = python3.withPackages (p: with p; [
      pyzmq
    ]);
  };
}
