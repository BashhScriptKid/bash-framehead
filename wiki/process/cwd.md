# `process::cwd`

Get process working directory

## Usage

```bash
process::cwd pid
```

## Source

```bash
process::cwd() {
    local pid="${1:-$$}"
    readlink "/proc/$pid/cwd" 2>/dev/null || \
        lsof -p "$pid" 2>/dev/null | awk '$4=="cwd"{print $9}'
}
```

## Module

[`process`](../process.md)
