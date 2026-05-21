# `process::retry`

**Signature:** `process::retry(times, delay, command, [args...])`

**Module:** [`process`](../process.md) — [Guide](../guide/index.md)

**Return:** exit code

## Description

Retry a command n times with a delay between attempts

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `times` | string | Yes | |
| `delay` | string | Yes | |
| `command` | command | Yes | |
| `args...` | string | No | |

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

