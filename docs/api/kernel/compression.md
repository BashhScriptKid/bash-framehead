# `kernel::compression`

**Signature:** `kernel::compression()`

**Module:** [`kernel`](../kernel.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::compression() {
	cat /sys/kernel/compression 2>/dev/null || echo "unknown"
}
```

