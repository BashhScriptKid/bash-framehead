# `process::job::status`

Get exit status of last background job

## Source

```bash
process::job::status() {
    wait "$1" 2>/dev/null
    echo $?
}
```

## Module

[`process`](../process.md)
