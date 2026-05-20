# `process::env`

Get process environment variable

## Usage

```bash
process::env pid varname
```

## Source

```bash
process::env() {
    local pid="$1" var="$2"
    if [[ -f "/proc/$pid/environ" ]]; then
        tr '\0' '\n' < "/proc/$pid/environ" | grep "^${var}=" | cut -d= -f2-
    fi
}
```

## Module

[`process`](../process.md)
