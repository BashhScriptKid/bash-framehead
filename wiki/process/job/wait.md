# `process::job::wait`

Wait for a specific background job by PID

## Source

```bash
process::job::wait() {
    wait "$1" 2>/dev/null
    return $?
}
```

## Module

[`process`](../process.md)
