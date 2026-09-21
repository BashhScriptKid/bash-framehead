# `device::read::queue_depth`

**Signature:** `device::read::queue_depth(arg1)`

**Module:** [`device`](../../device.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
device::read::queue_depth() {
		local _dev="$1" _base="${1##*/}"
		cat "/sys/block/${_base}/queue/nr_requests" 2>/dev/null || echo "unknown"
}
```

