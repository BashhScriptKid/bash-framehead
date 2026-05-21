# Example: File Change Detection and Integrity Checking

Uses `fs` and `hash` to build a build-cache guard: re-run expensive work only when input files have changed since the last run.

## The idea

Store a combined hash of input files in a state file. On the next run, hash the files again and compare. If the hash matches, skip the work. If any file changed, the hash differs and the work runs.

## Hashing individual files

Use `fs::checksum::sha256` to hash file contents. Do *not* use `hash::sha256` for this — that function hashes a string argument, not the contents of a file path.

```bash
file_hash=$(fs::checksum::sha256 "./src/main.c")
```

This single line replaces a common anti-pattern: `sha256sum ./src/main.c | awk '{print $1}'`.

## Combining multiple hashes

If you're watching multiple files, hash each one individually, then combine them into a single checksum with `hash::combine`:

```bash
combined=$(hash::combine \
    "$(fs::checksum::sha256 ./src/main.c)" \
    "$(fs::checksum::sha256 ./src/util.c)" \
    "$(fs::checksum::sha256 ./src/config.h)" \
)
```

`hash::combine` accepts any number of arguments and returns a single hash. The result changes if any input changes.

## Reading and writing the state file

```bash
state_file="./.build-state"

# Read previous hash
if fs::exists "$state_file"; then
    previous=$(fs::read "$state_file")
else
    previous=""
fi

# Compute current hash
current=$(hash::combine \
    "$(fs::checksum::sha256 ./src/main.c)" \
    "$(fs::checksum::sha256 ./src/util.c)" \
)

# Compare
if [[ "$current" == "$previous" ]]; then
    echo "No changes. Skipping build."
    exit 0
fi

# Do the build...
make

# Save the new state
fs::write "$state_file" "$current"
```

## A lighter alternative with timestamps

If the files are large and hashing is slow, `fs::find::recent` can serve as a pre-filter. It finds files modified within the last N minutes:

```bash
recent=$(fs::find::recent ./src 10)

if [[ -z "$recent" ]]; then
    echo "No files changed in the last 10 minutes. Skipping."
    exit 0
fi

# Something changed — hash to be sure, then decide
```

This works well for rapid rebuild loops: you probably care about "has anything changed in the last 60 seconds," not an exact diff against a stored state.

## The complete reusable function

```bash
#!/usr/bin/env bash
# Usage: has_inputs_changed <state_file> <file...>
# Returns 0 if inputs changed (build needed), 1 if unchanged (skip).
# Writes the new hash to the state file.

source "$(dirname "$0")/bash_framehead.sh"

has_inputs_changed() {
    local state_file="$1"
    shift

    local previous=""
    fs::exists "$state_file" && previous=$(fs::read "$state_file")

    local hashes=()
    local f
    for f in "$@"; do
        fs::exists "$f" || { echo "Missing: $f" >&2; return 2; }
        hashes+=("$(fs::checksum::sha256 "$f")")
    done

    local current
    current=$(hash::combine "${hashes[@]}")

    if [[ "$current" == "$previous" ]]; then
        return 1   # unchanged
    fi

    fs::write "$state_file" "$current"
    return 0   # changed
}

# ---------- usage ----------
if has_inputs_changed ".build-state" ./src/main.c ./src/util.c ./src/config.h; then
    echo "Inputs changed — rebuilding..."
    make
else
    echo "No changes."
fi
```
