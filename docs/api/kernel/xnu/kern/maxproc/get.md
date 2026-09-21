# `kernel::xnu::kern::maxproc::get`

**Signature:** `kernel::xnu::kern::maxproc::get()`

**Module:** [`kernel`](../../../../kernel.md) — [Guide](../../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::xnu::kern::maxproc::get() {
	sysctl -n kern.maxproc 2>/dev/null || echo "unknown"
}
```

