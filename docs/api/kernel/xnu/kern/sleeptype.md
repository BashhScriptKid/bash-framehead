# `kernel::xnu::kern::sleeptype`

**Signature:** `kernel::xnu::kern::sleeptype()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::xnu::kern::sleeptype() {
	sysctl -n kern.sleeptype 2>/dev/null || echo "unknown"
}
```

