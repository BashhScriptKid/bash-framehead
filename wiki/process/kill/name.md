# `process::kill::name`

Kill all processes matching a name

## Source

```bash
process::kill::name() {
    pkill -x "$1" 2>/dev/null
}
```

## Module

[`process`](../process.md)
