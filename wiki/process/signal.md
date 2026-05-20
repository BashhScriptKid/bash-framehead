# `process::signal`

Send a signal to a process

## Usage

```bash
process::signal pid signal
```

## Source

```bash
process::signal() {
    kill -"$2" "$1" 2>/dev/null
}
```

## Module

[`process`](../process.md)
