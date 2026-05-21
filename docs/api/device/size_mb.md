# `device::size_mb`

**Signature:** `device::size_mb(arg1)`

**Module:** [`device`](../device.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Returns the size of a block device in MB

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
device::size_mb() {
    local bytes
    bytes=$(device::size_bytes "$1")
    [[ "$bytes" == "unknown" ]] && echo "unknown" && return
    echo $(( bytes / 1024 / 1024 ))
}
```

