# bash::framehead — Project Context

## Project Overview

**bash::framehead** is a comprehensive Bash runtime standard library consisting of ~1,300 functions across 21 modules. It provides utilities for string manipulation, mathematics, filesystem operations, networking, Git, hardware introspection, terminal/colour handling, time/date operations, process management, and more — all compiled into a single sourceable Bash file.

**Philosophy:**
- **Single file distribution** — No dependencies, no installation, just `source compiled.sh`
- **Modular architecture** — 21 independent modules in `src/`, minimal coupling (only `runtime.sh` is required by all)
- **Implementation reference** — Every function is self-documenting; copy one and it works standalone
- **Bare-minimum compilation** — `./main.sh compile_bare "json::*"` emits only what's needed
- **Graceful degradation** — Runtime checks for required tools with helpful error messages
- **Consistent naming** — `module::function` convention throughout
- **Pure Bash where possible** — Integer math, string ops, arrays use no external tools; floating point uses `bc` when needed

## Project Structure

```
bash-framehead/
├── main.sh              # Homemade toolstack (auto-sourcer, compiler, compile_bare, stats, test runner)
├── tester.sh            # Test framework (~2000 lines of tests)
├── STYLING.md           # Authoritative style guide
├── src/                 # Source modules (21 .sh files)
│   ├── runtime.sh       # REQUIRED — base utilities all modules depend on
│   ├── array.sh         # Array operations (+ ::fast nameref variants)
│   ├── colour.sh        # ANSI colour/terminal styling
│   ├── device.sh        # Device/filesystem introspection
│   ├── fs.sh            # Filesystem operations
│   ├── git.sh           # Git repository operations
│   ├── hardware.sh      # CPU, RAM, disk, battery info
│   ├── hash.sh          # MD5, SHA*, CRC32, HMAC, etc.
│   ├── log.sh           # Logging utilities
│   ├── math.sh          # Integer/float math, vectors, matrices
│   ├── net.sh           # Network utilities (IP, DNS, HTTP)
│   ├── pfloat.sh        # Pure-Bash floating point (fixed-point, scale 10^5)
│   ├── pm.sh            # Package manager abstraction
│   ├── process.sh       # Process management, locks, signals
│   ├── random.sh        # RNG algorithms (LCG, xorshift, PCG32, etc.)
│   ├── string.sh        # String manipulation (+ ::fast nameref variants)
│   ├── terminal.sh      # Terminal control, cursor, input
│   └── timedate.sh      # Date/time/duration operations
├── wiki/                # Auto-generated documentation (git-ignored)
├── bash-framehead.sh    # Compiled output (git-ignored)
└── QWEN.md              # This file
```

## Building and Running

### Compile Modules

**Standard compilation:**
```bash
OPTIMIZE=0/1 MINIFY=0/1 ./main.sh compile {out.sh} << ''
```

**Bare-minimum compilation (call-graph tracing):**
```bash
# Compile only what 'json::*' transitively depends on
./main.sh compile_bare "json::*" json_bare.sh

# Or a single function + its helpers + its globals
./main.sh compile_bare "string::trim" trim.sh
```

`compile_bare` loads all functions and globals from `src/` and `ext/`, seeds
candidates from a glob pattern, then runs a fixed-point loop to discover
transitive dependencies (function calls + global variable references).  The
output is a minimal, self-contained script — no framework lock-in.

**Parameters:**
- `OPTIMIZE=0` — Skip optimization (faster compilation, larger output)
- `OPTIMIZE=1` — Enable optimization (slower compilation, smaller output)
- `MINIFY=0` — Skip minification (readable output, debug-friendly)
- `MINIFY=1` — Enable minification (smaller output, harder to debug)
- `<< ''` — Empty stdin redirection auto-generates version string (e.g., `devbuild-YYYYMMDD-HHMMSS`)

**Troubleshooting:**
- If compilation hangs, disable both flags: `OPTIMIZE=0 MINIFY=0`
- ShellCheck syntax errors may cause hangs — fix errors before compiling
- Version prompt appears if stdin is not redirected — use `<< ''` to auto-generate

**Alternative (manual version):**
```bash
echo "v1.0.0" | ./main.sh compile bash-framehead.sh
```

The compiler:
1. Concatenates all `src/*.sh` files
2. Strips duplicate shebangs (keeps only first)
3. Runs shellcheck (if available) and reports issues
4. Prompts for version string (auto-generates if skipped via `<< ''`)
5. Makes output executable

### Development Mode (No Compile)

For development/testing without compiling:

```bash
source ./main.sh
# Automatically sources all src/*.sh modules in order
# runtime.sh is sourced first, then all other modules
```

This is an officially supported workflow for rapid iteration — edit a module and re-source `main.sh` to reload everything.

### Run Tests

```bash
./main.sh test ./bash-framehead.sh
```

Test output shows PASS/FAIL/SKIP/UNTESTED for each function. Subtests (assertions within a test) are shown indented.

### View Statistics

```bash
./main.sh stat ./bash-framehead.sh
```

Shows:
- Version and file size
- Load time in milliseconds
- Functions per module
- Private helper count

### Usage in Scripts

```bash
#!/usr/bin/env bash
source ./bash-framehead.sh

# String operations
result=$(string::upper "hello world")

# Fast nameref pattern (no subshell)
string::upper::fast result "hello world"

# Array operations
arr=(1 2 3 4 5)
array::sum::fast sum "${arr[@]}"

# Math with pfloat (fixed-point, scale=10^5)
result=$(pfloat::add 1.5 2.5)
```

## Development Conventions

### Function Naming

- **Public functions:** `module::function_name` (e.g., `string::upper`)
- **Private helpers:** `_module::helper_name` (e.g., `_pfloat::_to_scaled`)
- **Fast variants:** `module::function::fast` — uses nameref pattern to avoid subshells

### Fast Nameref Pattern

For performance-critical code, functions provide `::fast` variants that use Bash namerefs instead of command substitution:

```bash
# Slow (subshell fork)
result=$(string::upper "hello")
count=$(array::length "${arr[@]}")

# Fast (nameref, no fork)
string::upper::fast result "hello"
array::length::fast count "${arr[@]}"
```

**Modules with ::fast variants:**
- `string::` — All case, trimming, substring, manipulation, encoding, naming convention functions
- `array::` — All inspection, transformation, filtering, aggregation, set operations

### Adding New Functions

1. Add to appropriate `src/<module>.sh`
2. Follow naming convention with full documentation comment:
   ```bash
   # Function description
   # Usage: module::function arg1 arg2
   module::function() {
       # implementation
   }
   ```
3. Add `::fast` variant if the function returns a modified value
4. Add tests to `tester.sh` under `test::module::function()`
5. Recompile: `./main.sh compile bash-framehead.sh`
6. Run tests: `./main.sh test ./bash-framehead.sh`

### Module Dependencies

- All modules depend on `runtime.sh` (OS detection, Bash version checks)
- **No horizontal dependencies** between other modules (design principle)
- If cross-module functionality is needed:
  - Copy trivial logic inline
  - Extract as private helper `_module::function`

### Testing Practices

Tests in `tester.sh` follow patterns:

```bash
# Simple pass/fail
test::string::upper() {
    if [[ "$(string::upper hello)" == "HELLO" ]]; then _pass; else _fail; fi
}

# Multiple assertions with subtests
test::string::contains() {
    _assert "contains (true)"  "0" "$(string::contains hello ell; echo $?)"
    _assert "contains (false)" "1" "$(string::contains hello xyz; echo $?)"
    _sub_done
}

# Skip for system-modifying or unavailable features
test::pm::install() {
    _skip "requires sudo/root — would modify system state"
}
```

### pfloat Module Notes

The `pfloat` module provides **pure-Bash floating point** arithmetic using fixed-point representation:

```bash
# Default scale is 5 (10^5 = 100,000)
# For more precision, set before sourcing:
pfloat_SCALE=7 source bash-framehead.sh
```

- Integer inputs use fast path (direct arithmetic, no scaling)
- Floating-point inputs are scaled, operated on, then unscaled
- Scale 5-8 recommended for 64-bit integer safety

## Key Files Reference

| File | Purpose |
|------|---------|
| `main.sh` | Homemade toolstack: auto-sourcer, compiler, statistics, test automation |
| `tester.sh` | Test framework with 2000+ test cases |
| `src/runtime.sh` | Base utilities (OS detection, Bash introspection) |
| `src/string.sh` | String manipulation (~200 functions) |
| `src/array.sh` | Array operations (~70 functions) |
| `src/math.sh` | Mathematics (~130 functions) |
| `src/pfloat.sh` | Pure-Bash floating point (fixed-point arithmetic) |

## Current Test Coverage

Based on recent test runs:
- **String module:** ~87 `::fast` variant tests + base tests
- **Array module:** ~31 `::fast` variant tests + base tests  
- **pfloat module:** ~44 tests (all passing with scale=5)
- **Overall:** 659+ passing tests, minimal untested functions

## Common Pitfalls

1. **Sourcing modules individually** — You can source individual modules, but **always source `runtime.sh` first**:
   ```bash
   source src/runtime.sh
   source src/string.sh
   # Now string:: functions are available
   ```
   Or just use `source ./main.sh` for development — it handles ordering automatically.

2. **Integer overflow in pfloat** — Keep scale ≤8 for 64-bit safety
3. **Nameref requires Bash 4.3+** — `::fast` variants won't work on older Bash
4. **Test functions must be named `test::module::function`** — Pattern matching in test runner
5. **Compiled file is git-ignored** — Each developer compiles their own

## 🛡️ Agent Behavior Guidelines (For Autonomous Mode)

When operating in autonomous/YOLO mode, you (the coding agent) MUST adhere to these rules:

### Core Principles
1. **Architecture is Law**: All code changes must align with the modular architecture defined in this document. Never bypass module boundaries, inject cross-module dependencies, or violate the `module::function` naming convention to "make tests pass."
2. **No Hacky Workarounds**: If a test fails, refactor the implementation — do NOT:
   - Hardcode values to satisfy assertions
   - Bypass interfaces or skip validation layers
   - Modify test files to match broken code
   - Use `eval`, dynamic `source`, or other meta-programming to circumvent constraints
3. **Plan Before Action**: For any non-trivial change:
   - First output a `<PLAN>` block summarizing the intended change
   - Verify the plan against the architecture rules above
   - Only then generate code
4. **Self-Audit Loop**: After generating code, briefly verify:
   - Does this change respect module isolation?
   - Are `::fast` variants used appropriately (Bash 4.3+, nameref pattern)?
   - Would this change break graceful degradation or pure-Bash goals?

### Failure Conditions (STOP and Ask)
If any of these occur, you MUST stop autonomous execution and request human review:
- A required tool (`bc`, `git`, `shellcheck`) is missing and cannot be gracefully degraded
- A change would require modifying `runtime.sh` (the core dependency)
- A test conflict suggests the architecture itself needs revision
- You've made 3+ iterative changes to the same function without success

### Preferred Patterns
✅ **Do**:
- Use `string::upper::fast result "input"` pattern for performance-critical code
- Add new functions to the appropriate `src/<module>.sh` with full documentation
- Write tests in `tester.sh` using `_assert`/`_sub_done` patterns
- Keep `pfloat_SCALE` ≤8 for 64-bit safety

❌ **Don't**:
- Source modules out of order (always `runtime.sh` first)
- Use external dependencies beyond what's documented (e.g., no `jq` unless `net.sh` already uses it)
- Generate code that assumes Bash >4.3 without checking `runtime::bash_version`

### Reminder
You are optimizing for **long-term maintainability**, not short-term test passes. A failing test that exposes an architectural flaw is more valuable than a passing test built on a hack.

If in doubt: **STOP, summarize the conflict, and ask for guidance**.

## Qwen Added Memories
### Coding Style
- See [STYLING.md](STYLING.md) for the authoritative style guide.
- **Indentation**: tabs only. **Separators**: `# --- Section ---`.
- **Variable naming**: self-documenting; exemptions for loop counters, coords, colors, PRNG state, Unix abbrevs.
- **Algebraic leeway**: `{letter}_{disambiguated}` for math (`_W_weights`, `_lr_learning_rate`).
- **Niche-context**: obscure domains use explicit names (`_codepoint` over `_cp`).

### IEEE 754 Implementation
- ✅ Fully integrated into `src/pfloat.sh` — no longer stashed WIP.
- **Functions**: `add`, `sub`, `mul`, `div`, `sqrt`, `eq`, `ne`, `lt`, `le`, `gt`, `ge`, `is_nan`, `is_inf`, `is_finite`, `is_zero`, `is_negative`, `is_positive`, `neg`, `abs`, `sign`, `from_string`, `to_string`, `dump`, `from_binary`, `to_binary`, `trunc`, `round`
- Bit-manipulation constants kept as `readonly` for clarity.

### Compiler Automation Syntax
- **Command**: `OPTIMIZE=0/1 MINIFY=0/1 ./main.sh compile {out.sh} << ''`
- **Flags**:
  - `OPTIMIZE=0` — Fast compile, larger output (dev)
  - `OPTIMIZE=1` — Slow compile, smaller output (prod)
  - `MINIFY=0` — Readable output (debug)
  - `MINIFY=1` — Minified output (release)
- **`<< ''`** — Auto-generates version (e.g., `devbuild-20260316-083000`)
- **Hangs**: If compilation hangs, use `OPTIMIZE=0 MINIFY=0` and check for ShellCheck syntax errors
- **Stashed backup**: Work saved to git stash for future sessions
- Test patterns: `test::module::function()` naming required. Use `_assert "label" "expected" "actual"` for assertions, `_sub_done` after multiple assertions, `_skip "reason"` for unavailable features. 659+ passing tests.
- Agent guidelines: Architecture is law — no hacky workarounds, no cross-module dependencies, no eval/dynamic source. Plan before action with <PLAN> block. STOP if: required tool missing, change needs runtime.sh modification, test conflict suggests architecture revision, 3+ iterative changes without success.
- bash::framehead compiler syntax: `OPTIMIZE=0/1 MINIFY=0/1 ./main.sh compile {out.sh} << ''` — empty stdin auto-generates version. If hangs, use OPTIMIZE=0 MINIFY=0 and fix ShellCheck errors first. IEEE 754 implementation stashed at `git stash@{0}: ieee754-implementation-wip` with backup at `bash-framehead_ieee754_wip.sh`. pfloat::fixed::* (46 functions) working, pfloat::ieee754::* (22 functions) has mul/div bugs.
