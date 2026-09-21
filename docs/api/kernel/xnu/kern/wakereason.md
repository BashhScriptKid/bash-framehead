# `kernel::xnu::kern::wakereason`

**Signature:** `kernel::xnu::kern::wakereason()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::xnu::kern::wakereason() {
	sysctl -n kern.wakereason 2>/dev/null || echo "unknown"
}
```

