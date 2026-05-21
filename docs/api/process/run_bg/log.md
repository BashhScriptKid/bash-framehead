# `process::run_bg::log`

**Signature:** `process::run_bg::log(logfile, command, [args...])`

**Module:** [`process`](../../process.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Run a command in the background, redirect output to a log file

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `logfile` | string | Yes | |
| `command` | command | Yes | |
| `args...` | string | No | |

## Source

```bash
process::run_bg::log() {
    local logfile="$1"; shift
    "$@" >> "$logfile" 2>&1 &
    echo $!
}
```

