# `process::is_running::name`

Check if a process is running by name

## Usage

```bash
process::is_running::name name
```

## Source

```bash
process::is_running::name() {
    pgrep -x "$1" >/dev/null 2>&1
}
```

## Module

[`process`](../process.md)
