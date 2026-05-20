# bash-framehead

A comprehensive Bash standard library framework with **~785 functions** across **18 modules** — pure Bash where possible, with minimal external dependencies.

## Overview

bash-framehead provides a modular, single-file runtime library covering string manipulation, math (including vectors and matrices), filesystem operations, networking, git, hardware detection, colour/terminal control, time/date handling, process management, cryptography-grade random number generation, and more.

### Quick Start

```bash
# Compile all modules into a single distributable file
./main.sh compile bash-framehead.sh

# Source it in your script
source ./bash-framehead.sh

# Now use any function
string::upper "hello world"        # → HELLO WORLD
math::factorial 5                  # → 120
fs::size ./somefile
```

### Development Mode

```bash
# Source main.sh directly for rapid iteration (loads all modules)
source ./main.sh
```

---

## Modules

| Module | Functions | Description |
|--------|-----------|-------------|
| [`runtime`](./runtime.md) | 54 | Shell state, OS detection, terminal capabilities |
| [`string`](./string.md) | 204 | Inspection, case conversion, naming conventions, trimming, encoding |
| [`math`](./math.md) | 150 | Integer/float arithmetic, vectors (vec2/vec3), matrices, trigonometry |
| [`fs`](./fs.md) | 79 | Path manipulation, file checks, I/O, temp files, directory ops |
| [`array`](./array.md) | 42 | Construction, transformation, filtering, aggregation, set ops, sorting |
| [`net`](./net.md) | 38 | Connectivity, DNS, HTTP fetching, IP/interface info, whois |
| [`colour`](./colour.md) | 65 | ANSI escape codes, 4/8/24-bit colour, text styling |
| [`device`](./device.md) | 25 | Block/character device inspection, listing, classification |
| [`git`](./git.md) | 35 | Repo state, branches, commits, remotes, tags |
| [`hardware`](./hardware.md) | 36 | CPU, GPU, RAM, disk, partitions, battery |
| [`hash`](./hash.md) | 25 | Cryptographic and non-cryptographic hashing, HMAC, UUID5 |
| [`log`](./log.md) | 10 | Structured logging with severity levels and route configuration |
| [`pfloat`](./pfloat.md) | 129 | Fixed-point and IEEE 754 floating-point arithmetic in pure Bash |
| [`pm`](./pm.md) | 5 | Cross-distribution package manager abstraction |
| [`process`](./process.md) | 51 | Process query, resource usage, control, locking, services |
| [`random`](./random.md) | 25 | PRNG algorithms (Xoshiro, PCG, WELL512, ISAAC, etc.) |
| [`terminal`](./terminal.md) | 74 | Cursor control, screen buffer, input handling, shopt wrappers |
| [`timedate`](./timedate.md) | 76 | Timestamps, dates, times, durations, calendar, timezone conversion |

---

## Conventions

### Naming

```
module::function              # Public API
module::function::fast        # Optimized variant using namerefs
module::function::subtype     # Specialized variant
_module::helper               # Internal/private helper
```

### Input Patterns

Most functions support both argument input and stdin piping:

```bash
string::upper "hello"         # argument
echo "hello" | string::upper  # pipe
```

### Fast Variants

Functions with `::fast` suffix use bash namerefs to write results directly into a variable, avoiding subshell overhead:

```bash
# Standard: forks a subshell
result=$(string::upper "hello")

# Fast: no subshell, writes directly to result_var
string::upper::fast result_var "hello"
echo "$result_var"
```

### Return Values

- **Inspection functions** (e.g., `string::is_empty`, `fs::exists`): return exit code 0 (true) or 1 (false)
- **Transform functions** (e.g., `string::upper`, `math::abs`): print result to stdout
- **Fast variants**: take result variable name as first argument
- **Integer functions**: use native bash arithmetic
- **Float functions** (suffixed `f`): delegate to `bc`

---

## Requirements

- **Bash 4.3+** minimum (associative arrays, namerefs)
- **Bash 5.0+** recommended (some features like `array::unique::fast` require it)
- **GNU coreutils** `bc` required for floating-point and some matrix/trig functions
- Individual functions document their external tool requirements

## Build System

```bash
# Development build (fast, no optimization)
OPTIMIZE=0 MINIFY=0 ./main.sh compile bash-framehead.sh <<< ''

# Optimized build
OPTIMIZE=1 MINIFY=0 ./main.sh compile bash-framehead.sh <<< ''

# Full production build
OPTIMIZE=1 MINIFY=1 ./main.sh compile out.sh <<< ''

# Run tests
./main.sh test ./bash-framehead.sh

# Show statistics
./main.sh stat ./bash-framehead.sh
```
