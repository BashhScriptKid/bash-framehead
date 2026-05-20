# `process::retry`

Retry a command n times with a delay between attempts

## Usage

```bash
process::retry times delay command [args...]
```

## Source

```bash
process::retry() {
    local tries="$1" delay="$2"; shift 2
    local attempt=0
    while (( attempt < tries )); do
        "$@" && return 0
        (( attempt++ ))
        (( attempt < tries )) && sleep "$delay"
    done
    return 1
}
```

## Module

[`process`](../process.md)
