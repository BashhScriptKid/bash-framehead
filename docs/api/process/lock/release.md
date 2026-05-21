# `process::lock::release`

**Signature:** `process::lock::release(lockname)`

**Module:** [`process`](../../process.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Release a lock

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `lockname` | string | Yes | |

## Source

```bash
process::lock::release() {
    rm -f "/tmp/fsbshf_${1}.lock"
}
```

