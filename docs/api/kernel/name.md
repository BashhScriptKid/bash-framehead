# `kernel::name`

**Signature:** `kernel::name()`

**Module:** [`kernel`](../kernel.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::name() {
	uname -s 2>/dev/null || echo "unknown"
}
```

