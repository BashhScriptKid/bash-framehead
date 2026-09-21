# `kernel::arch`

**Signature:** `kernel::arch()`

**Module:** [`kernel`](../kernel.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::arch() {
	uname -m 2>/dev/null || echo "unknown"
}
```

