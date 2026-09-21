# `kernel::xnu::kern::bootsessionuuid`

**Signature:** `kernel::xnu::kern::bootsessionuuid()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::xnu::kern::bootsessionuuid() {
	sysctl -n kern.bootsessionuuid 2>/dev/null || echo "unknown"
}
```

