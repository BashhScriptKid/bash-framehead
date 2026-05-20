# `process::is_running`

Check if a process is running by PID

## Usage

```bash
process::is_running pid
```

## Source

```bash
process::is_running() {
    kill -0 "$1" 2>/dev/null
}
```

## Module

[`process`](../process.md)
