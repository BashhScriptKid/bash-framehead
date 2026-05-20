# `process::cpu`

Get CPU usage percentage for a PID

## Usage

```bash
process::cpu pid
```

## Source

```bash
process::cpu() {
    ps -o pcpu= -p "$1" 2>/dev/null | tr -d ' '
}
```

## Module

[`process`](../process.md)
