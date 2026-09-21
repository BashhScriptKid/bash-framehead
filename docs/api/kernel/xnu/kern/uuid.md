# `kernel::xnu::kern::uuid`

**Signature:** `kernel::xnu::kern::uuid()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::xnu::kern::uuid() {
	sysctl -n kern.uuid 2>/dev/null || echo "unknown"
}
```

