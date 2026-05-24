# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`bash::framehead` is a comprehensive Bash standard library framework. It's a modular, single-file runtime library with ~785 functions across 16 modules for string manipulation, math, filesystem operations, networking, git, hardware, colour, terminal, time, process management, and more.

## Architecture

- **Modular source**: Functions are organized in `src/` directory as separate `.sh` files (e.g., `string.sh`, `math.sh`, `runtime.sh`)
- **Single-file output**: Source modules are compiled into a single distributable file using `main.sh compile` (core only) or `main.sh compile_extended` (core + extensions)
- **Runtime dependency**: `runtime.sh` is required by all other modules
- **Function naming**: `module::function` convention (e.g., `string::upper`, `math::factorial`)
- **Private helpers**: `_module::helper` naming for internal functions
- **Fast variants**: `module::function::fast` for optimized versions using namerefs

## Build System

The main entry point is `main.sh` with these commands:

### Compilation
```bash
# Basic compilation (no optimization/minification)
./main.sh compile [output_file]  # defaults to compiled.sh

# Development build (fast)
OPTIMIZE=0 MINIFY=0 ./main.sh compile bash-framehead.sh <<< ''

# Optimized build (no minification)
OPTIMIZE=1 MINIFY=0 ./main.sh compile bash-framehead.sh <<< ''

# Full optimize + minify (slow, can hang)
OPTIMIZE=1 MINIFY=1 ./main.sh compile out.sh <<< ''

# Extended compilation (core + all extensions)
./main.sh compile_extended [output_file]  # defaults to bash-framehead-extended.sh

# Extended with optimize
OPTIMIZE=1 MINIFY=0 ./main.sh compile_extended out.sh
```

`compile_extended` compiles core modules first, then processes each extension in
`ext/` with compile-time dependency validation:

- Parses each extension's header block (`# Dependencies: core: ... external: ...`)
  and guard arrays (`_guard_core_deps`, `_guard_ext_deps`)
- Cross-checks header vs guard — warns on mismatch
- Verifies every listed core function exists in the compiled core (`declare -f`)
- Verifies every listed external tool is on `PATH` (`command -v`)
- Supports `|`-separated alternative deps (e.g. `nc|socat|tcpserver` — any one must be present)
- Runs ShellCheck on every extension file (same as core)
- Fails fast if any dependency is missing — no silent degradation
- Strips guard blocks and header comments from the final output
```

### Testing
```bash
# Run all tests on compiled file
./main.sh test ./bash-framehead.sh

# Development mode - source all modules for rapid editing
source ./main.sh
```

### Analysis
```bash
# Show framework statistics
./main.sh stat ./bash-framehead.sh

# Profile function loading
./main.sh profile ./bash-framehead.sh
```

### Optimization & Minification
```bash
# Optimize a single file
./main.sh optimize input.sh output.sh

# Minify files
./main.sh minify input.sh output.sh
```

## Testing Framework

- Tests are defined in `tester.sh` with `test::module::function()` naming
- Use `_assert "label" "expected" "actual"` for assertions
- Group related assertions with `_sub_done`
- Skip environment-sensitive tests with `_skip "reason"`
- Test results show: PASS, FAIL, SKIP, UNTESTED status

## Documentation Generation

```bash
# Generate/update wiki documentation
./wiki-gen.sh ./bash-framehead.sh ./wiki
```

- Function pages are created once and preserved (manual edits kept)
- Module indexes append new entries
- Root index appends new module rows
- Uses the framework itself for string manipulation and path handling

## Obfuscation/Minification

The `obfuscate.sh` script provides standalone obfuscation:
```bash
# Obfuscate a script
./obfuscate.sh input.sh output.sh

# With specific passes
./obfuscate.sh --obfuscate=functions,strings input.sh output.sh
```

Passes: `private_functions`, `functions`, `local_variables`, `variables`, `strings`

## Development Guidelines

1. **Module independence**: Modules should not depend on each other except via `runtime.sh`
2. **Pure Bash preferred**: Use external tools only where necessary (e.g., `bc` for floats)
3. **Function comments**: Comments directly above function definitions are extracted for documentation
4. **ShellCheck**: Compilation runs ShellCheck; strict mode (`OPTIMIZE=1` or `MINIFY=1`) fails on errors
5. **New modules**: Create `src/module.sh`, add to compile list in `main.sh`, add tests, generate docs

## Extensions (`ext/`)

Extensions are optional modules that layer on top of the core library. Unlike core
modules, they can depend on any number of core modules and external tools. They are
**not compiled into the main distribution** — source them separately after
`bash-framehead.sh`.

### Extension API surface (49 functions across 6 modules)

| Extension | Functions | Highlights |
|-----------|-----------|------------|
| **json** | 20 | `get`, `keys`, `type`, `len`, `validate`, `kv` (stateful context + read/write) |
| **csv** | 8 | `get`, `row`, `col`, `headers`, `numrows`, `numcols`, `to_json` |
| **ini** | 7 | `get`, `keys`, `sections`, `to_json`, `set`, `remove` |
| **yaml** | 4 | `to_json`, `get`, `get_file`, `keys` |
| **toml** | 4 | `to_json`, `get`, `get_file`, `keys` |
| **dotenv** | 6 | `get`, `keys`, `to_json`, `load`, `load_assoc` |

### Extension conventions
- **Directory per extension**: `ext/<name>/` contains `<name>.sh`, `docs.md`, `test_ext.sh`
- **Guard block**: Every extension checks `runtime::bash_version` exists and declares
  `_guard_core_deps` / `_guard_ext_deps` arrays at source time
- **Naming**: `extension::function` for public API, `_extension::helper` for internals,
  `extension::sub::sub` for sub-namespaced APIs (e.g., `json::kv::value::get`)
- **Global config vars**: Some extensions use globals for configuration
  (`CSV_NOHEADER`, `CSV_DELIMITER`)
- **Positional arguments only**: No `--flags` — all arguments are positional
- **Stateful singletons**: `json::kv` uses global `_json_kv_*` context (single instance)

### Adding a new extension
1. Create `ext/<name>/` with `<name>.sh`, `docs.md`, `test_ext.sh`
2. Follow the guard block template from `ext/README.md`
3. Source after core: `source ./bash-framehead.sh && source ./ext/<name>/<name>.sh`
4. Run tests: source `tester.sh` after the extension, then call `test::<name>::*`
5. Benchmarks: place in `<name>.sh` or a separate `benchmark.sh`

## File Organization

- `src/` - Source modules (`*.sh` files)
- `ext/` - Optional extensions (json, csv, ini, yaml, toml, dotenv)
- `main.sh` - Main entry point (compile, test, stat, profile)
- `tester.sh` - Test framework (~2000 test functions)
- `wiki-gen.sh` - Documentation generator
- `obfuscate.sh` - Obfuscator/minifier
- `wiki/` - Generated documentation
- `*.sh` files at root - Compiled/experimental builds (git-ignored)

## Important Notes

- **Runtime requirement**: `runtime.sh` is a shared dependency for all modules
- **Bash version**: Requires Bash 4.3+ (associative arrays, namerefs); some functions need 5.0+
- **Generated files**: Compiled outputs (`bash-framehead*.sh`) are git-ignored
- **Minifier performance**: The minifier can be slow/hang; use `MINIFY=0` for development
- **Strict mode**: `OPTIMIZE=1` or `MINIFY=1` enables strict ShellCheck validation
- **GNU grep**: The json extension's fast path uses `grep -b` (byte-offset) which is
  GNU-specific. macOS users need `brew install grep`

## Common Workflows

### Adding a core function
1. Add function to appropriate module in `src/`
2. Add test to `tester.sh` as `test::module::function()`
3. Compile: `OPTIMIZE=0 MINIFY=0 ./main.sh compile bash-framehead.sh <<< ''`
4. Test: `./main.sh test ./bash-framehead.sh`
5. Generate docs: `./wiki-gen.sh ./bash-framehead.sh ./wiki`

### Adding an extension function
1. Add function to `ext/<name>/<name>.sh`
2. Add test to `ext/<name>/test_ext.sh`
3. Update `ext/<name>/docs.md`
4. Source and test: `source ./bash-framehead.sh && source ./ext/<name>/<name>.sh && source ./tester.sh && test::<name>::*`

### Debugging minifier issues
1. Use non-minified builds: `MINIFY=0`
2. Add temporary progress logs to minifier
3. Fall back to `OPTIMIZE=0 MINIFY=0` if minifier hangs

### Rapid development
```bash
source ./main.sh  # Sources all modules for immediate testing
# Edit modules in src/, test functions directly
```