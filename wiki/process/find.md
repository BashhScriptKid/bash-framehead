# `process::find`

Find processes matching a pattern (name or cmdline)

## Usage

```bash
process::find pattern
```

## Source

```bash
process::find() {
    pgrep -a "$1" 2>/dev/null || ps -eo pid,args | grep "$1" | grep -v grep
}
```

## Module

[`process`](../process.md)
