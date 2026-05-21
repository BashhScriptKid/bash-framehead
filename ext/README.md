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
source ./bash-framehead.sh      # always first
source ./ext/my-extension.sh    # then extensions
```

If you forget, you'll get a clear error — extensions check that the runtime is present before doing anything.

## Dependency declaration

Every extension must declare its dependencies in two places: a **header block** at the top of the file, and a **guard** that runs at source time. Both must list the same set of dependencies. No silent assumptions.

### Header block

The first non-shebang lines of the file spell out exactly what the module needs:

```bash
# ext/docker.sh
#
# Dependencies:
#   core: runtime string fs
#   external: docker

# ext/gitlab-mr.sh
#
# Dependencies:
#   core: runtime net string colour
#   external: curl jq fzf
```

- **`core:`** — specific core modules this extension uses. Never just "the framework." Name each one.
- **`external:`** — external tools the extension invokes. Binaries that aren't guaranteed on every system.

### Source-time guard

Copy the template below into your extension. Fill in the two arrays — that's it. The guard loop doesn't change between modules.

```bash
# ext/your-module.sh
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
- One-off scripts — this is still a library, not a scripts directory
- Things that modify core behaviour — extensions layer on top, they don't monkey-patch

## Conventions

- Naming follows core style: `extensionname::function_name`
- Each extension is a single `.sh` file
- An extension checks its dependencies at source time and fails with a clear message if the core library is missing
- Heavy init work goes in a setup function, not at source time
