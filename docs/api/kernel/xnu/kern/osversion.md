# `kernel::xnu::kern::osversion`

**Signature:** `kernel::xnu::kern::osversion()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- XNU: Kernel ---


## Source

```bash
kernel::xnu::kern::osversion() {
	sysctl -n kern.osversion 2>/dev/null || echo "unknown"
}
```

