{ nixpkgs ? import builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/871b9fd269ff6246794583ce4ee1031e1da71895.tar.gz";
    sha256 = "1zn1lsafn62sz6azx6j735fh4vwwghj8cc9x91g5sx2nrg23ap9k";
  } {}
, withGui ? false
, withWallet ? true
, withTests ? true
, doCheck ? true
}:
{
  bitcoin = with nixpkgs; callPackage ./bitcoin.nix {
    stdenv = clang19Stdenv;
    inherit (qt5) qtbase qttools wrapQtAppsHook;
    inherit (darwin) autoSignDarwinBinariesHook;
    python3 = python3.withPackages (p: with p; [
      pyzmq
    ]);
  };
}
