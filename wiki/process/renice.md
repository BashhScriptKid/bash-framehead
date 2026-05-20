# `process::renice`

Change process priority (nice value, -20 to 19)

## Usage

```bash
process::renice pid value
```

## Source

```bash
process::renice() {
    renice -n "$2" -p "$1" 2>/dev/null
}
```

## Module

[`process`](../process.md)
