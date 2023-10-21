# Bitcoin Nix Tools

"The only reason why I am not a Core developer yet is because the setup is so hard."

Nix derivations to locally build and test Bitcoin Core and Elements Core.

No more complicated configuration.

Let's make Bitcoin Core development as easy as possible!

## Spread the nix

Step zero is to clone this repo and the repo you want to infect with nix.

In this example, we use Bitcoin Core.

```bash
git clone git@github.com:uncomputable/bitcoin-nix-tools.git
git clone git@github.com:bitcoin/bitcoin.git
```

Then copy the nix files over.

```bash
cp bitcoin-nix-tools/*.nix bitcoin
```

You have successfully spread the nix.

## Develop Bitcoin Core

Open a nix shell with the [default settings](https://github.com/uncomputable/bitcoin-nix-tools/blob/master/shell.nix#L1-L5).

```bash
nix-shell
```

Alternatively, open a shell with custom settings by passing arguments.

```bash
nix-shell --arg withGui true
```

### Build Bitcoin Core

Run the build commands with default settings.

```bash
./autogen.sh
./configure
make # use "-j N" for N parallel jobs
```

The configure script lists the available options and default values.

```bash
./configure --help
```

Read more about building in the [official README](https://github.com/bitcoin/bitcoin/blob/master/doc/build-unix.md).

### Test Bitcoin Core

First, build Bitcoin Core (see above).

Then run the boost tests.

```bash
make test # use "-j N" for N parallel jobs
```

Or run the functional tests.

```bash
python3 test/functional/test_runner.py # use "--extended" to include ignored tests
```

Read more about testing in the [official README](https://github.com/bitcoin/bitcoin/blob/master/test/README.md).

### Fuzz Bitcoin Core

Run the build commands with fuzzing and sanitizers enabled.

```bash
./autogen.sh
./configure --enable-fuzz --with-sanitizers=address,fuzzer,undefined
make # use "-j N" for N parallel jobs
```

Run a fuzzing target.

```bash
FUZZ=process_message src/test/fuzz/fuzz
```

The variable `FUZZ` selects the fuzzing target.

Targets are .cpp files in the [fuzz folder](https://github.com/bitcoin/bitcoin/tree/master/src/test/fuzz).

Run the following command to list all targets.

```bash
grep -rl '^FUZZ_TARGET' src/test/fuzz | xargs -I {} basename {} .cpp
```

Download the [QA assets](https://github.com/bitcoin-core/qa-assets) for a massive headstart in code coverage.

```bash
git clone git@github.com:bitcoin-core/qa-assets.git
```

Run the fuzzer with the corpus directory set to the respective target in QA assets.

```bash
FUZZ=process_message src/test/fuzz/fuzz qa-assets/fuzz_seed_corpus/process_message/
```

Read more about fuzzing in the [official README](https://github.com/bitcoin/bitcoin/blob/master/doc/fuzzing.md).

## Build Bitcoin Core

Build the package with the [default settings](https://github.com/uncomputable/bitcoin-nix-tools/blob/master/default.nix#L1-L6).

```bash
nix-build -A bitcoin
```

Alternatively, build the package with custom settings by passing arguments.

```bash
nix-build -A bitcoin --arg withGui true --arg doCheck false
```

## Elements Core

At the time of this writing (2023-10-18), you can build Elements Core almost the same way as Bitcoin Core.

Simply follow the instructions for Bitcoin Core.

**There is one thing you need to do.**

Include the argument `$configureFlags` when you call the configure script. This applies also to fuzzing.

_For some reason, Bitcoin Core 26 is more nix-friendly than Elements 22. This issue will likely resolve itself eventually._

```bash
./configure $configureFlags
```

For completeness, I will link the READMEs on [building](https://github.com/ElementsProject/elements/blob/master/doc/build-unix.md) and [testing](https://github.com/ElementsProject/elements/blob/master/test/README.md).
