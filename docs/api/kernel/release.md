# `kernel::release`

**Signature:** `kernel::release()`

**Module:** [`kernel`](../kernel.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::release() {
	uname -r 2>/dev/null || echo "unknown"
}
```

