# `process::lock::wait`

**Signature:** `process::lock::wait(lockname, [timeout])`

**Module:** [`process`](../../process.md) — [Guide](../../guide/index.md)

**Return:** exit code

## Description

Wait for a lock to become available

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `lockname` | string | Yes | |
| `timeout` | string | No | |

## Source

```bash
process::lock::wait() {
    local name="$1" timeout="${2:-30}" elapsed=0
    while ! process::lock::acquire "$name"; do
        sleep 1
        (( elapsed++ ))
        (( elapsed >= timeout )) && return 1
    done
    return 0
}
```

