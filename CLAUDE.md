# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`bash::framehead` is a comprehensive Bash standard library framework. It's a modular, single-file runtime library with ~785 functions across 16 modules for string manipulation, math, filesystem operations, networking, git, hardware, colour, terminal, time, process management, and more.

## Architecture

- **Modular source**: Functions are organized in `src/` directory as separate `.sh` files (e.g., `string.sh`, `math.sh`, `runtime.sh`)
- **Single-file output**: Source modules are compiled into a single distributable file using `main.sh compile`
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

## File Organization

- `src/` - Source modules (`*.sh` files)
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

## Common Workflows

### Adding a new function
1. Add function to appropriate module in `src/`
2. Add test to `tester.sh` as `test::module::function()`
3. Compile: `OPTIMIZE=0 MINIFY=0 ./main.sh compile bash-framehead.sh <<< ''`
4. Test: `./main.sh test ./bash-framehead.sh`
5. Generate docs: `./wiki-gen.sh ./bash-framehead.sh ./wiki`

### Debugging minifier issues
1. Use non-minified builds: `MINIFY=0`
2. Add temporary progress logs to minifier
3. Fall back to `OPTIMIZE=0 MINIFY=0` if minifier hangs

### Rapid development
```bash
source ./main.sh  # Sources all modules for immediate testing
# Edit modules in src/, test functions directly
```