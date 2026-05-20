# `process::suspend`

Suspend a process (SIGSTOP)

## Source

```bash
process::suspend() {
    kill -STOP "$1" 2>/dev/null
}
```

## Module

[`process`](../process.md)
