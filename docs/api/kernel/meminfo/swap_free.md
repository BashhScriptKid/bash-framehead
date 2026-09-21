# `kernel::meminfo::swap_free`

**Signature:** `kernel::meminfo::swap_free(arg2)`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg2` | string | Yes | |

## Source

```bash
kernel::meminfo::swap_free() {
	awk '/^SwapFree:/{printf "%.0f", $2/1024}' /proc/meminfo 2>/dev/null || echo "unknown"
}
```

