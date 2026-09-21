# `kernel::xnu::kern::bootuuid`

**Signature:** `kernel::xnu::kern::bootuuid()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::xnu::kern::bootuuid() {
	sysctl -n kern.bootuuid 2>/dev/null || echo "unknown"
}
```

