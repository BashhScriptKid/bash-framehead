# Compiling

## When you need this

If you downloaded `bash_framehead.sh` from the [releases page](https://github.com/BashhScriptKid/bash-framehead/releases), you don't need to compile. The release file is ready to source.

Compiling from source is for:
- Building a custom subset with only the modules you need
- Staying on the latest unreleased changes between releases
- Contributing changes back to the project

## Full compile

```bash
git clone https://github.com/BashhScriptKid/bash-framehead.git
cd bash-framehead
./main.sh compile
# → compiled.sh
```

`runtime.sh` is always included — every other module depends on it.

The compiler supports environment flags for controlling output quality:

```bash
# Fast development build
OPTIMIZE=0 MINIFY=0 ./main.sh compile bash-framehead.sh <<< ''

# Optimized (runs ShellCheck, inlines helpers)
OPTIMIZE=1 MINIFY=0 ./main.sh compile bash-framehead.sh <<< ''

# Full production (optimize + minify — can be slow)
OPTIMIZE=1 MINIFY=1 ./main.sh compile out.sh <<< ''
```

For day-to-day development, `OPTIMIZE=0 MINIFY=0` is fast and sufficient.

## Custom subset

You might not need all 21 modules in every project. A smaller file means faster source time and less memory in constrained environments.

To exclude modules, remove their `.sh` file from the `src/` directory before compiling, or edit the compile list in `main.sh`. `runtime.sh` must stay — it is required.

A script that only needs string utilities and filesystem operations:

```bash
# Keep only: src/runtime.sh, src/string.sh, src/fs.sh
# Remove everything else from the compile list, then:
./main.sh compile my-stdlib.sh
```

## Distributing with your project

**Vendor it.** Commit the compiled file into your repo and source it relatively. Simple, self-contained, never breaks because of an upstream change.

```bash
source "$(dirname "$0")/lib/bash_framehead.sh"
```

Tradeoff: you have to remember to recompile and commit when you want upstream changes.

**Git submodule.** Track bash-framehead as a submodule and compile as part of your project's setup step.

```bash
git submodule add https://github.com/BashhScriptKid/bash-framehead.git lib/bash-framehead
cd lib/bash-framehead
./main.sh compile ../../bash_framehead.sh
```

Tradeoff: more setup for contributors, but staying current is one `git pull` away.

Vendoring is the right default for most projects. Use a submodule if you expect to track upstream closely.

## Bare-minimum (call‑graph tracing)

For the smallest possible build containing only the functions needed for a specific pattern, use `compile_bare`:

```bash
./main.sh compile_bare "json::*" json_bare.sh && source ./json_bare.sh
```

This command traces the call graph for the given pattern and emits only the required functions and globals—ideal for constrained environments.

## Verifying the build

```bash
./main.sh stat ./compiled.sh
```

Prints per-module function counts and total load time. Example output:

```
Module        Functions
runtime       54
string        204
fs            74
...

Total: ~1,300 functions
Load time: 0.12s
```

Run the test suite to catch regressions:

```bash
./main.sh test ./compiled.sh
```

A passing run shows `PASS` for each test group. Failures print the assertion that broke and the expected vs actual values.
