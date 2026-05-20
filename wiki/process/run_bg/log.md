# `process::run_bg::log`

Run a command in the background, redirect output to a log file

## Usage

```bash
process::run_bg::log logfile command [args...]
```

## Source

```bash
process::run_bg::log() {
    local logfile="$1"; shift
    "$@" >> "$logfile" 2>&1 &
    echo $!
}
```

## Module

[`process`](../process.md)
