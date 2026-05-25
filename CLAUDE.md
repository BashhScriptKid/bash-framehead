# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`bash::framehead` is a comprehensive Bash standard library framework. It's a modular, single-file runtime library with ~1,300 functions across 21 modules for string manipulation, math, filesystem operations, networking, git, hardware, colour, terminal, time, process management, and more.

## Architecture

- **Modular source**: Functions are organized in `src/` directory as separate `.sh` files (e.g., `string.sh`, `math.sh`, `runtime.sh`)
- **Extensions**: Additional modules in `ext/` layer on top of the core with documented `# Requires:` headers
- **Single-file output**: Source modules are compiled into a single distributable file using `main.sh compile` (core only), `main.sh compile_extended` (core + extensions), or `main.sh compile_bare` (call-graph subset)
- **Runtime dependency**: `runtime.sh` is required by all core modules
- **Function naming**: `module::function` convention (e.g., `string::upper`, `math::factorial`)
- **Private helpers**: `_module::helper` naming for internal functions
- **Fast variants**: `module::function::fast` for optimized versions using namerefs

## Style Guide

The authoritative style reference is [STYLING.md](STYLING.md). Key conventions:
- **Tabs** for indentation; soft 80-column limit
- **Section separators**: `# --- Section Name ---`
- **Variable names**: self-documenting except loop counters (`i`/`j`/`k`), coords (`x`/`y`/`z`), colors (`r`/`g`/`b`), PRNG state (`s0`/`s1`), Unix abbrevs (`_fd`/`_pid`)
- **Algebraic leeway**: math variables use `{letter}_{disambiguated}` (`_W_weights`, `_lr_learning_rate`)
- **Niche-context rule**: obscure domains require explicit names (`_codepoint` over `_cp`)

## Build System

### Compilation
```bash
# Development build (fast)
OPTIMIZE=0 MINIFY=0 ./main.sh compile bash-framehead.sh <<< ''

# Optimized build
OPTIMIZE=1 MINIFY=0 ./main.sh compile bash-framehead.sh <<< ''

# Bare-minimum compile — only what a pattern transitively needs
./main.sh compile_bare "json::*" json_bare.sh

# Extended compilation (core + all extensions)
./main.sh compile_extended bash-framehead-extended.sh
```

`compile_bare` works by:
1. Loading all functions + globals from `src/` and `ext/` into a map
2. Seeding candidates from a glob pattern (e.g. `json::*`)
3. Fixed-point loop: scanning candidate bodies for `module::function` calls and `$GLOBAL` references, adding newly discovered deps
4. Emitting only the reached functions and globals as a self-contained script

### Testing
```bash
./main.sh test ./bash-framehead.sh       # Run all tests
source ./main.sh                          # Dev mode — source all modules live
```

### Analysis
```bash
./main.sh stat ./bash-framehead.sh       # Show framework statistics
./main.sh profile ./bash-framehead.sh    # Profile function loading
```

## Testing Framework

- Tests are defined in `tester.sh` with `test::module::function()` naming
- Use `_assert "label" "expected" "actual"` for assertions
- Group related assertions with `_sub_done`
- Skip environment-sensitive tests with `_skip "reason"`

## Extensions (`ext/`)

Extensions are self-contained units that depend on core modules (documented via `# Requires:` headers). They are compiled separately or via `compile_bare`.

| Extension | Functions | Highlights |
|-----------|-----------|-------------|
| **json** | 20 | `get`, `keys`, `type`, `len`, `validate`, `kv` (stateful context + read/write) |
| **csv** | 8 | `get`, `row`, `col`, `headers`, `numrows`, `numcols`, `to_json` |
| **ini** | 7 | `get`, `keys`, `sections`, `to_json`, `set`, `remove` |
| **yaml** | 4 | `to_json`, `get`, `get_file`, `keys` |
| **toml** | 4 | `to_json`, `get`, `get_file`, `keys` |
| **dotenv** | 6 | `get`, `keys`, `to_json`, `load`, `load_assoc` |
| **http-server** | — | Pure Bash HTTP server |
| **neural** | — | Neural network implementation |
| **bmp** | — | Bitmap image parser |
| **wav** | — | WAV audio parser |

## Development Guidelines

1. **Module independence**: Modules should not depend on each other except via `runtime.sh`
2. **Pure Bash preferred**: Use external tools only where necessary (e.g., `bc` for floats)
3. **Self-documenting code**: Functions should be understandable in isolation — copy one function and it should work
4. **ShellCheck**: Compilation runs ShellCheck; strict mode (`OPTIMIZE=1` or `MINIFY=1`) fails on errors
5. **Use `compile_bare`** to verify new functions don't pull in unintended transitive dependencies

## Common Workflows

### Adding a core function
1. Add function to appropriate module in `src/`
2. Add test to `tester.sh` as `test::module::function()`
3. Compile: `OPTIMIZE=0 MINIFY=0 ./main.sh compile bash-framehead.sh <<< ''`
4. Test: `./main.sh test ./bash-framehead.sh`

### Creating a minimal subset
```bash
# Get only what 'json::*' needs
./main.sh compile_bare "json::*" json_bare.sh
# Result: ~40 functions, no unused code, ready to source standalone
```

### Important Notes
- **Runtime requirement**: `runtime.sh` is a shared dependency for all modules
- **Bash version**: Requires Bash 4.3+ (associative arrays, namerefs); some functions need 5.0+
- **Minifier performance**: The minifier can be slow/hang; use `MINIFY=0` for development
