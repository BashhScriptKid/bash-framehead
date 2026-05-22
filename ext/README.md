# ext/ — Optional Extensions

Extensions that don't fit cleanly into framehead's constrained module architecture. Unlike core modules, extensions are free to depend on any number of core modules (not just `runtime`) and can pull in external tools without the usual "pure Bash where possible" constraint. They are not compiled into the main distribution — source them separately after the core library.

## How this differs from core modules

Core modules follow strict rules:
- **Single dependency** — `runtime.sh` only, no horizontal coupling
- **Pure Bash preferred** — external tools only where truly necessary
- **Compiled in** — every core module ships in `bash-framehead.sh`

Extensions relax all of that:
- **Any dependency** — need `string`, `fs`, `net`, and `git`? Go ahead
- **External tools welcome** — `jq`, `yq`, `fzf`, `docker`, whatever gets the job done
- **Sourced separately** — `source ext/something.sh` after the core library

## Usage

The core library must be loaded first. No exceptions.

```bash
source ./bash-framehead.sh          # always first
source ./ext/json/json.sh           # then the extension you need
```

If you forget, you'll get a clear error — extensions check that the runtime is present before doing anything.

## Dependency declaration

Every extension must declare its dependencies in two places: a **header block** at the top of the file, and a **guard** that runs at source time. Both must list the same set of dependencies. No silent assumptions.

### Header block

The first non-shebang lines of the file spell out exactly what the module needs:

```bash
# ext/json/json.sh
#
# Dependencies:
#   core: runtime string
#   external: grep
```

- **`core:`** — specific core modules this extension uses. Never just "the framework." Name each one.
- **`external:`** — external tools the extension invokes. Binaries that aren't guaranteed on every system.

### Source-time guard

Copy the template below into your extension. Fill in the two arrays — that's it. The guard loop doesn't change between modules.

```bash
# ext/<name>/<name>.sh
#
# Dependencies:
#   core: runtime string
#   external: jq

# --- guard (copy this block, replace the array contents) ---

# runtime is mandatory — checked once, hardcoded, no need to list it below
declare -f 'runtime::bash_version' &>/dev/null || {
    echo "${BASH_SOURCE[0]}: runtime not found — source bash-framehead.sh first" >&2
    return 1
}

_guard_core_deps=(string::trim fs::exists)
_guard_ext_deps=(jq)

for _guard_dep in "${_guard_core_deps[@]}"; do
    declare -f "$_guard_dep" &>/dev/null || {
        echo "${BASH_SOURCE[0]}: missing core function '$_guard_dep'" >&2
        return 1
    }
done

for _guard_dep in "${_guard_ext_deps[@]}"; do
    command -v "$_guard_dep" &>/dev/null || {
        echo "${BASH_SOURCE[0]}: missing external tool '$_guard_dep'" >&2
        return 1
    }
done

unset _guard_core_deps _guard_ext_deps _guard_dep
# --- end guard ---
```

**What you change:**
- `_guard_core_deps` — list `module::function` symbols your extension calls, from modules **outside `runtime`**. Runtime is checked separately — don't list it here.
- `_guard_ext_deps` — list external binaries your extension invokes. Leave empty `()` if you have none.

**What you don't touch:** the runtime check, the two `for` loops, and the `unset` line. Those are identical in every extension.

The guard checks both categories:
- **Core functions** — `declare -f` verifies the function symbol exists in the current shell. If it doesn't, the core library wasn't sourced (or the wrong module set was compiled).
- **External tools** — `command -v` verifies the binary is on `PATH`.

Failures print the module name, the specific missing dependency, and (for core deps) a hint about what went wrong — then bail with `return 1`. No silent degradation, no guessing.

## What belongs here

- Domain-specific tooling that pulls in heavy dependencies (Docker, cloud CLIs, etc.)
- Modules that need multiple core modules and would violate the single-dependency rule
- Experimental or niche functions that don't justify inclusion in the main library
- Wrappers around interactive tools (`fzf`, `gum`, `dialog`)
- Glue code between framehead and third-party CLIs

## What doesn't belong here

- General-purpose functions that could be a core module — those go in `src/`
- One-off scripts — each extension is a self-contained directory with docs and tests
- Things that modify core behaviour — extensions layer on top, they don't monkey-patch

## Conventions

- Naming follows core style: `extensionname::function_name`
- An extension checks its dependencies at source time and fails with a clear message if the core library is missing
- Heavy init work goes in a setup function, not at source time

## Directory Structure

Each extension lives in its own directory under `ext/` with a fixed set of files:

```
ext/
├── README.md              ← this file (conventions, not a specific extension)
├── json/
│   ├── json.sh            ← the extension module (sourced by the user)
│   ├── docs.md            ← API reference, dependencies, limitations
│   └── test_ext.sh        ← test functions using the tester.sh convention
├── docker/                ← future: ext/docker/
│   ├── docker.sh
│   ├── docs.md
│   └── test_ext.sh
└── ...
```

### File purposes

| File | Required | Purpose |
|------|----------|---------|
| `<name>.sh` | yes | The extension module. Users source this after `bash-framehead.sh`. |
| `docs.md` | yes | API docs, dependency list, usage examples, known limitations. |
| `test_ext.sh` | yes | Test functions named `test::<name>::function`. Sourced by `main.sh test` after the core test pass. Uses `_pass` / `_fail` / `_assert` / `_sub_done` / `_skip` from `tester.sh`. |

### `test_ext.sh` contract

The test runner (`main.sh test`) discovers and runs extension tests automatically. Each
`test_ext.sh` must:

1. **Define test functions** named `test::<name>::<thing>` — e.g. `test::json::get::basic`.
2. **Use the tester.sh primitives** — `_pass`, `_fail`, `_assert`, `_assert_contains`,
   `_assert_nonempty`, `_sub_done`, `_skip`. These are provided by the core tester and are
   **already in scope** when `test_ext.sh` is sourced. Do not redeclare or redefine them.
3. **Not call any test directly** — the runner enumerates `declare -F` to find test
   functions and calls each one through `_tester_reset`.
4. **Skip heavy/network tests** — use `_skip "reason"` for tests that download data,
   require credentials, or take more than a few seconds. The runner can optionally
   enable them.

Example:
```bash
# ext/json/test_ext.sh

test::json::get::basic() {
    _assert "string" 'hello' "$(json::get '{"k":"hello"}' k)"
    _assert "number" '42'    "$(json::get '{"k":42}'     k)"
    _sub_done
}

test::json::stress::canada() {
    # downloads 2.2 MB file — skip by default
    _skip "large file download"
}
```
