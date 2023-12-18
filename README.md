# Bitcoin Nix Tools

"The only reason why I'm not a Core developer yet is because the setup is too hard."

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

## Test Bitcoin Core

### Enter the development environment

Open a nix shell.

```bash
nix-shell # use "--arg withGui true" to include GUI
```

### Build Bitcoin Core

Run the automake commands.

```bash
./autogen.sh
./configure $configureFlags
make # use "-j N" for N parallel jobs
```

The configure script lists the available options and default values.

```bash
./configure --help
```

### Read more about building

Read the [official README](https://github.com/bitcoin/bitcoin/blob/master/doc/build-unix.md).

### Run the unit tests

Use make to run the boost unit tests.

```bash
make test # use "-j N" for N parallel jobs
```

### Run the functional tests

Use python to run the functional tests.

```bash
python3 test/functional/test_runner.py # use "-j N" for N parallel jobs # use "--extended" to include ignored tests
```

### Run the QA asset unit tests

Download the [QA assets](https://github.com/bitcoin-core/qa-assets).

```bash
git clone git@github.com:bitcoin-core/qa-assets.git
```

Use the test runner to run the QA asset unit tests.

```bash
DIR_UNIT_TEST_DATA=qa-assets/unit_test_data ./src/test/test_bitcoin --log_level=warning --run_test=script_tests
```

The variable `DIR_UNIT_TEST_DATA` selects the directory in which the file `script_assets_test.json` is located.

### Read more about testing

Read the [official README](https://github.com/bitcoin/bitcoin/blob/master/test/README.md).

## Fuzz Bitcoin Core

### Enter the development environment

Open a nix shell.

```bash
nix-shell # use "--arg withGui true" to include GUI
```

### Build Bitcoin Core

Run the automake commands with fuzzing and sanitizers enabled.

```bash
./autogen.sh
./configure $configureFlags --enable-fuzz --with-sanitizers=address,fuzzer,undefined
make # use "-j N" for N parallel jobs
```

### Run a fuzzing target

Use the compiled fuzzer binary to run a fuzzing target.

```bash
FUZZ=process_message src/test/fuzz/fuzz
```

The variable `FUZZ` selects the fuzzing target.

Run the following command to list all targets.

```bash
grep -rl '^FUZZ_TARGET' src/test/fuzz | xargs -I {} basename {} .cpp
```

### Fuzz using the QA asset seed corpus

Download the [QA assets](https://github.com/bitcoin-core/qa-assets) for a massive headstart in code coverage.

```bash
git clone git@github.com:bitcoin-core/qa-assets.git
```

Pass the corpus directory of the respective target to the fuzzer binary.

The `FUZZ` variable and the folder in the corpus must be the same.

```bash
FUZZ=process_message src/test/fuzz/fuzz qa-assets/fuzz_seed_corpus/process_message/
```

### Read more about fuzzing

Read the [official README](https://github.com/bitcoin/bitcoin/blob/master/doc/fuzzing.md).

## Generate QA asset unit test data

### Generate unit tests dumps

[Build Bitcoin Core for testing](https://github.com/uncomputable/bitcoin-nix-tools/tree/master#test-bitcoin-core).

Then run the Taproot tests a couple of times and dump the output in a directory.

```bash
mkdir dump
for N in $(seq 1 10); do TEST_DUMP_DIR=dump test/functional/feature_taproot.py --dumptests; done
```

### Compress test dumps via fuzz merging

[Build Bitcoin Core for fuzzing](https://github.com/uncomputable/bitcoin-nix-tools/tree/master#fuzz-bitcoin-core).

Then run the `script_assets_test_minimizer` fuzz test in merge mode and dump the output in another directory.

Use shell commands to create a .json file.

```bash
mkdir dump-min
FUZZ=script_assets_test_minimizer ./src/test/fuzz/fuzz -merge=1 -use_value_profile=1 dump-min/ dump/
(echo -en '[\n'; cat dump-min/* | head -c -2; echo -en '\n]') > script_assets_test.json
```

## Test code coverage of Bitcoin Core

### Enter the development environment

Open a nix shell.

```bash
nix-shell # use "--arg withGui true" to include GUI
```

### Build Bitcoin Core

Run the automake commands with line and branch coverage enabled.

Disable BDB to avoid compiling and testing the legacy wallet.

```bash
./autogen.sh
./configure $configureFlags --enable-lcov --enable-lcov-branch-coverage --disable-bdb
make # use "-j N" for N parallel jobs
```

The compiled binaries will log their coverage in separate files each time they are run.

### Test unit test coverage

Use make to run the unit tests and to compile an HTML coverage report.

```bash
make test_bitcoin.coverage/.dirstamp # use "-j N" for N parallel jobs
```

Open the report in your browser.

```bash
firefox test_bitcoin.coverage/src/index.html
```

### Test total coverage

Use make to run the unit and functional tests, and to compile an HTML coverage report.

```bash
make cov # use "-j N" for N parallel jobs
```

Open the report in your browser.

```bash
firefox test_bitcoin.coverage/src/index.html
```

## Elements Core

You can build, test and fuzz Elements Core exactly the same way as Bitcoin Core :)

For completeness, I will link the READMEs on [building](https://github.com/ElementsProject/elements/blob/master/doc/build-unix.md) and [testing](https://github.com/ElementsProject/elements/blob/master/test/README.md).
