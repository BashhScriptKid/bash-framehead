# `process::is_zombie`

Check if a process is a zombie

## Source

```bash
process::is_zombie() {
    [[ "$(process::state "$1")" == "Z" ]]
}
```

## Module

[`process`](../process.md)
