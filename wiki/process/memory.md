# `process::memory`

Get memory usage in KB for a PID

## Usage

```bash
process::memory pid
```

## Source

```bash
process::memory() {
    if [[ -f "/proc/$1/status" ]]; then
        awk '/^VmRSS:/{print $2}' "/proc/$1/status"
    else
        ps -o rss= -p "$1" 2>/dev/null | tr -d ' '
    fi
}
```

## Module

[`process`](../process.md)
