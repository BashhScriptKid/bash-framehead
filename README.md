# bash::framehead

A framework for Bash — a runtime standard library with a comprehensive (and frankly ridiculous) set of helpers. String manipulation, math, filesystem, networking, git, hardware, colour, terminal, time, process management, and more — all compiled into a single sourceable file.
No dependencies beyond what's already on your system. No installation. Just source it and go.

```bash
source ./compiled.sh

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

## Getting started

Clone the repo and compile the framework into a single file:

```bash
git clone https://github.com/BashhScriptKid/bash-framehead.git
cd bash-framehead
./main.sh compile
# → compiled.sh
```

You can also specify an output filename:

```bash
./main.sh compile myproject-stdlib.sh
```

Source it in any script:

```bash
source /path/to/compiled.sh

# Now everything is available
colour::fg::green "$(string::upper "it works")"
```

Or drop it next to your script and source it relatively:

```bash
source "$(dirname "$0")/compiled.sh"
```

---

## Modules

16 modules, ~785 functions.

| Module | Functions | What it does |
|--------|-----------|--------------|
| [`string`](./wiki/string.md) | 115 | Case conversion, padding, splitting, encoding, validation, UUID, base64/32 |
| [`fs`](./wiki/fs.md) | 79 | Read/write, paths, find, checksums, temp files, symlinks, permissions |
| [`timedate`](./wiki/timedate.md) | 74 | Dates, times, durations, timezones, calendars, stopwatch |
| [`terminal`](./wiki/terminal.md) | 74 | Cursor, screen, shopt, colour detection, input |
| [`colour`](./wiki/colour.md) | 65 | 4-bit, 8-bit, 24-bit colour, ANSI escapes, strip, wrap |
| [`math`](./wiki/math.md) | 107 | Integer, float, vec2/3 and matrix operations, trig, stats, unit conversion |
| [`process`](./wiki/process.md) | 51 | Query, signal, lock, retry, timeout, jobs, services |
| [`runtime`](./wiki/runtime.md) | 50 | OS/arch detection, shell flags, environment introspection |
| [`array`](./wiki/array.md) | 42 | Slice, sort, filter, set ops, zip, chunk, rotate |
| [`net`](./wiki/net.md) | 38 | IP, DNS, HTTP, interfaces, fetch, ping, port scan |
| [`git`](./wiki/git.md) | 35 | Branch, commit, status, stash, tags, remotes |
| [`hardware`](./wiki/hardware.md) | 34 | CPU, RAM, GPU, disk, battery, partitions |
| [`device`](./wiki/device.md) | 25 | Block devices, loop, TTY, mount, filesystem |
| [`hash`](./wiki/hash.md) | 23 | MD5, SHA*, HMAC, FNV, DJB2, CRC32, UUID5, slots |
| [`random`](./wiki/random.md) | 22 | Native, LCG, xorshift, PCG32, xoshiro, ISAAC, WELL512 |
| [`pm`](./wiki/pm.md) | 5 | Package manager abstraction (apt/pacman/brew/dnf/…) |

Full documentation lives in [`wiki/`](./wiki/).

---

## Common tasks

**Compile** the source modules into a single distributable file:

```bash
./main.sh compile
# → compiled.sh

./main.sh compile myname.sh
# → myname.sh
```

**Print framework statistics** — load time, total functions, per-module breakdown:

```bash
./main.sh stat ./compiled.sh
```

**Run the test suite:**

```bash
./main.sh test ./compiled.sh
# === Results: 659 passed, 0 failed, 8 skipped, 1 untested ===
# === Success rate: 100.0% (659/659) ===
```

**Generate or update the wiki:**

```bash
./gen_wiki.sh ./compiled.sh ./wiki
```

The wiki generator sources the compiled framework and uses it to introspect itself — function pages are created once and skipped on subsequent runs so manual edits are preserved. Module index pages append new entries rather than overwrite.

---

## Project layout

```
bash-framehead/
├── main.sh               # Entry point — compile, test, stat
├── compiled.sh           # Compiled single-file output
├── gen_wiki.sh           # Wiki generator
├── src/
│   ├── runtime.sh        # Required — everything depends on this
│   ├── array.sh
│   ├── colour.sh
│   ├── device.sh
│   ├── fs.sh
│   ├── git.sh
│   ├── hardware.sh
│   ├── hash.sh
│   ├── math.sh
│   ├── net.sh
│   ├── pm.sh
│   ├── process.sh
│   ├── random.sh
│   ├── string.sh
│   ├── terminal.sh
│   └── timedate.sh
└── wiki/
    ├── README.md
    ├── string.md
    ├── string/
    │   ├── upper.md
    │   ├── lower.md
    │   └── ...
    └── ...
```

---

## Adding a new module

1. Create `src/yourmodule.sh` with functions following the `yourmodule::function_name` convention
2. Add it to the compile list in `main.sh`
3. Recompile: `./main.sh compile`
4. Add tests to the `tester()` function in `main.sh`
5. Run: `./main.sh test ./compiled.sh`
6. Generate wiki pages: `./gen_wiki.sh ./compiled.sh ./wiki`

Function comments directly above a definition are picked up by the wiki generator:

```bash
# Convert string to uppercase
# Usage: yourmodule::shout str
yourmodule::shout() {
    string::upper "$1"
}
```

> [!IMPORTANT]
> Modules submitted upstream must not depend on other modules except `runtime.sh`
> to avoid horizontal dependencies. If you need logic from another module, either
> copy it inline (for trivial usage) or extract it as a private helper under the
> `_module::function` naming convention.
>
> Personal forks and local builds are free to ignore this.
---

### Why is the said 'single-file framework' file not included in the repository tree?

The repository tree is meant for when you actually want to do more than just 'download one file in releases and leave'

Including a pre-compiled file also risks it drifting out of sync with the source in src/, so we'd rather you compile it yourself. It's one command, and you get the flexibility of the modular architecture as a bonus.

---

## Requirements

- Bash 4.3+ (associative arrays, namerefs)
- Bash 5.0+ for a handful of functions (guarded with `runtime::is_minimum_bash 5`)
- Standard GNU coreutils (`awk`, `sed`, `find`, `sort`)
- Optional: `bc` for floating point math, `curl`/`wget` for networking, `openssl` for crypto hashes, `git` for git repository based operation

---

## Licence

[AGPL-3.0](./LICENSE)
