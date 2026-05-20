# `process::lock::wait`

Wait for a lock to become available

## Usage

```bash
process::lock::wait lockname [timeout]
```

## Source

```bash
process::lock::wait() {
    local name="$1" timeout="${2:-30}" elapsed=0
    while ! process::lock::acquire "$name"; do
        sleep 1
        (( elapsed++ ))
        (( elapsed >= timeout )) && return 1
    done
    return 0
}
```

## Module

[`process`](../process.md)
