# `process::memory::percent`

Get memory usage as percentage

## Source

```bash
process::memory::percent() {
    ps -o pmem= -p "$1" 2>/dev/null | tr -d ' '
}
```

## Module

[`process`](../process.md)
