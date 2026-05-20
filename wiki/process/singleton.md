# `process::singleton`

Run command only if not already running (singleton)

## Usage

```bash
process::singleton lockname command [args...]
```

## Source

```bash
process::singleton() {
    local name="$1"; shift
    if process::lock::acquire "$name"; then
        "$@"
    else
        echo "process::singleton: '$name' is already running" >&2
        return 1
    fi
}
```

## Module

[`process`](../process.md)
