# bash::framehead

A framework for Bash — a runtime standard library with a comprehensive (and frankly ridiculous) set of helpers. String manipulation, math, filesystem, networking, git, hardware, colour, terminal, time, process management, and more — all compiled into a single sourceable file. No dependencies beyond what's already on your system. No installation. Just source it and go.

```bash
source ./bash-framehead.sh

string::upper "hello world"      # HELLO WORLD
math::factorial 10               # 3628800
fs::exists ./myfile && echo "found"
timedate::duration::format 3661  # 1h 1m 1s
```

---

## Why?

Bash is everywhere. But writing robust scripts in Bash usually means reinventing the same wheels — trimming strings, checking if a port is open, formatting durations, hashing a value, reading a file line by line. Every project ends up with its own grab-bag of utility functions, copy-pasted from Stack Overflow and subtly different each time.

`bash::framehead` is that grab-bag, done once and done properly. It follows a few guiding principles:

- **Single file.** Source one file, get everything. No `PATH` gymnastics, no install scripts, no package managers.
- **Modular by design.** Don't need networking? Pull out `net.sh`. Don't need colour? Drop `colour.sh`. Modules have minimal coupling to each other — as long as `runtime.sh` is kept, the rest can be mixed and matched freely and the compiler will handle it cleanly.
- **Graceful degradation.** Functions check for required tools at runtime and fail cleanly with a helpful message if something's missing, rather than cryptic errors mid-script.
- **Consistent naming.** Everything follows `module::function` convention. No guessing whether it's `str_upper` or `upper_str` or `toUpper`.
- **Pure Bash where possible.** Integer math, string manipulation, array operations — no unnecessary subshells or external tools. Floating point uses `bc` when needed and says so.
- **No magic.** No global state mutation behind your back, no surprise side effects. Functions take input, return output.

---

## Don't want the entire framework?

No worries — the enforced code style keeps every function self-documenting,
so individual functions work as standalone **implementation references**.
Copy what you need, inherit framehead's robustness, leave the rest.

Even better — run `compile_bare` to get exactly the minimum needed for your
project:

```bash
# Compile only what 'json::*' transitively depends on
./main.sh compile_bare "json::*" json_bare.sh

# Or just one function + its helpers + its globals
./main.sh compile_bare "string::trim" trim.sh
```

It traces the full call graph — functions, private helpers, global
variables — and emits a single self-contained script.  No framework,
no lock-in, just the parts you actually use.

---

## Getting started

Clone the repo and compile the framework into a single file:

```bash
git clone https://github.com/BashhScriptKid/bash-framehead.git
cd bash-framehead
./main.sh compile
# → bash-framehead.sh
```

You can also specify an output filename:

```bash
./main.sh compile myproject-stdlib.sh
```

Source it in any script:

```bash
source /path/to/bash-framehead.sh

# Now everything is available
colour::fg::green "$(string::upper "it works")"
```

Or drop it next to your script and source it relatively:

```bash
source "$(dirname "$0")/bash-framehead.sh"
```

---

## Modules

18 modules, ~785 functions across 1,117 API definitions (including `::fast` variants).

| Module | Functions | Description |
|--------|-----------|-------------|
| `runtime` | 54 | Shell state, OS detection, terminal capabilities |
| `string` | 204 | Inspection, case, naming conventions, trimming, encoding |
| `math` | 150 | Integer/float arithmetic, vec2/vec3, matrices, trigonometry |
| `fs` | 79 | Path manipulation, file checks, I/O, temp files, directory ops |
| `array` | 42 | Construction, transformation, filtering, set ops, sorting |
| `net` | 38 | Connectivity, DNS, HTTP, interfaces, whois |
| `colour` | 65 | ANSI escape codes, 4/8/24-bit colour, text styling |
| `device` | 25 | Block/character device inspection, classification |
| `git` | 35 | Repo state, branches, commits, remotes, tags |
| `hardware` | 36 | CPU, GPU, RAM, disk, partitions, battery |
| `hash` | 25 | Crypto + non-crypto hashing, HMAC, UUID5 |
| `log` | 10 | Structured logging with severity levels and routing |
| `pfloat` | 129 | Fixed-point and IEEE 754 floating-point arithmetic |
| `pm` | 5 | Cross-distribution package manager abstraction |
| `process` | 51 | Process query, control, locking, services |
| `random` | 25 | PRNG algorithms — from LCG to ISAAC |
| `terminal` | 74 | Cursor control, screen buffer, input handling, shopt |
| `timedate` | 76 | Timestamps, dates, times, durations, timezones |

Full documentation lives in [`docs/`](./docs/). The [Getting Started guide](./docs/guides/getting-started.md) covers first use, the [examples](./docs/guides/examples/) walk through real patterns, and the [API Dictionary](./docs/api/index.md) lists every function alphabetically.

---

## Common tasks

**Compile** the source modules into a single distributable file:

```bash
# Development build (fast)
OPTIMIZE=0 MINIFY=0 ./main.sh compile bash-framehead.sh <<< ''

# Optimized build
OPTIMIZE=1 MINIFY=0 ./main.sh compile bash-framehead.sh <<< ''

# Full production build (minifier can be slow)
OPTIMIZE=1 MINIFY=1 ./main.sh compile out.sh <<< ''
```

**Print framework statistics** — load time, total functions, per-module breakdown:

```bash
./main.sh stat ./bash-framehead.sh
```

**Run the test suite:**

```bash
./main.sh test ./bash-framehead.sh
```

**Regenerate API documentation** from source:

```bash
bash tools/api-gen.sh src docs/api
```

**Development mode** — source all modules directly without compiling:

```bash
source ./main.sh
```

---

## Project layout

```
bash-framehead/
├── main.sh               # Entry point — compile, test, stat
├── README.md
├── src/
│   ├── runtime.sh        # Required — everything depends on this
│   ├── array.sh
│   ├── colour.sh
│   ├── device.sh
│   ├── fs.sh
│   ├── git.sh
│   ├── hardware.sh
│   ├── hash.sh
│   ├── log.sh
│   ├── math.sh
│   ├── net.sh
│   ├── pfloat.sh
│   ├── pm.sh
│   ├── process.sh
│   ├── random.sh
│   ├── string.sh
│   ├── terminal.sh
│   └── timedate.sh
├── tools/
│   ├── api-gen.sh        # API reference generator
│   └── wiki-gen.sh       # Old wiki generator (legacy, superseded by api-gen.sh)
└── docs/
    ├── SKILL.md          # Framework quick-reference for models
    ├── MODEL_NOTES.md    # State journal
    ├── guides/            # Narrative guides, examples, and tutorials
    │   └── examples/     # Worked examples: installer, retry, integrity, colour
    └── api/              # Generated per-function API reference
        └── index.md      # Function dictionary (alphabetical index)
```

---

## Adding a new module

1. Create `src/yourmodule.sh` with functions following the `yourmodule::function_name` convention
2. Add it to the compile list in `main.sh`
3. Recompile: `./main.sh compile bash-framehead.sh`
4. Add tests to `tester.sh` following `test::yourmodule::function()` naming
5. Run: `./main.sh test ./bash-framehead.sh`
6. Regenerate API docs: `bash tools/api-gen.sh src docs/api`

Modules submitted upstream must not depend on other modules except `runtime.sh` to avoid horizontal dependencies. If you need logic from another module, either copy it inline (for trivial usage) or extract it as a private helper under the `_module::function` naming convention. Personal forks and local builds are free to ignore this.

---

### Why isn't the compiled file in the repository?

Including a pre-compiled file risks it drifting out of sync with the source in `src/`. Compile it yourself — it's one command, and you get the flexibility of the modular architecture as a bonus.

---

## Requirements

- **Bash 4.3+** (associative arrays, namerefs)
- **Bash 5.0+** for a handful of functions (guarded with `runtime::is_minimum_bash 5`)
- Standard GNU coreutils (`awk`, `sed`, `find`, `sort`)
- Optional: `bc` for floating point math, `curl`/`wget` for networking, `openssl` for crypto hashes, `git` for git operations

---

## Licence

[AGPL-3.0](./LICENSE)
