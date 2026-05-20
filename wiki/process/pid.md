# `process::pid`

Get PID(s) of a named process (one per line)

## Usage

```bash
process::pid name
```

## Source

```bash
process::pid() {
    pgrep -x "$1" 2>/dev/null
}
```

## Module

[`process`](../process.md)
