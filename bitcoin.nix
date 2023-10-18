{ lib
, stdenv
, autoreconfHook
, pkg-config
, util-linux
, hexdump
, autoSignDarwinBinariesHook
, wrapQtAppsHook ? null
, boost
, libevent
, miniupnpc
, zeromq
, zlib
, db48
, sqlite
, qrencode
, qtbase ? null
, qttools ? null
, python3
, withGui ? false
, withWallet ? true
, withTests ? true
, doCheck ? true
, parallelBuild ? true
}:

assert doCheck -> withTests;

stdenv.mkDerivation {
  pname = if withGui then "bitcoin" else "bitcoind";
  version = "dev";

  # TODO: specify accurate source
  # src = lib.sourceFilesBySuffices ./. [ ".ac" ".am" ".m4" ".in" ".include" ".mk" ".h" ".hpp" ".c" ".cc" ".cpp" ".inc" ".py" ".json" ".raw" ".sh" ".1" ".hex" ".csv" ".html" "Makefile" ];
  src = lib.cleanSource (lib.cleanSourceWith {
    filter = name: type:
      let
        baseName = baseNameOf (toString name);
      in
        !(lib.hasSuffix ".cache" baseName || lib.hasSuffix ".Po" baseName);
    src = ./.;
  });

  nativeBuildInputs =
    [ autoreconfHook pkg-config ]
    ++ lib.optionals stdenv.isLinux [ util-linux ]
    ++ lib.optionals stdenv.isDarwin [ hexdump ]
    ++ lib.optionals (stdenv.isDarwin && stdenv.isAarch64) [ autoSignDarwinBinariesHook ]
    ++ lib.optionals withGui [ wrapQtAppsHook ];

  buildInputs = [ boost libevent miniupnpc zeromq zlib ]
    ++ lib.optionals withWallet [ db48 sqlite ]
    ++ lib.optionals withGui [ qrencode qtbase qttools ];

  configureFlags = [
    "--with-boost-libdir=${boost.out}/lib"
    "--disable-bench"
  ] ++ lib.optionals (!withTests) [
    "--disable-tests"
    "--disable-gui-tests"
  ] ++ lib.optionals (!withWallet) [
    "--disable-wallet"
  ] ++ lib.optionals withGui [
    "--with-gui=qt5"
    "--with-qt-bindir=${qtbase.dev}/bin:${qttools.dev}/bin"
  ];

  enableParallelBuilding = parallelBuild;
  makeFlags = [ "VERBOSE=true" ];

  nativeCheckInputs = [ python3 ];

  checkFlags = [
    "LC_ALL=en_US.UTF-8"
  ] ++ lib.optionals withGui [
    # QT_PLUGIN_PATH needs to be set when executing QT, which is needed when testing Bitcoin's GUI.
    # See also https://github.com/NixOS/nixpkgs/issues/24256
    "QT_PLUGIN_PATH=${qtbase}/${qtbase.qtPluginPrefix}"
  ];

  testRunnerFlags = [ ] ++ lib.optionals parallelBuild [ "-j=$NIX_BUILD_CORES" ];
  postCheck = if doCheck
  then ''
    patchShebangs test/functional
    (cd test/functional && python3 test_runner.py $testRunnerFlags)
  ''
  else "";

  meta = with lib; {
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
