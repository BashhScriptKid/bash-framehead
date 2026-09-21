# `kernel::bsd::kern::maxfiles::get`

**Signature:** `kernel::bsd::kern::maxfiles::get()`

**Module:** [`kernel`](../../../../kernel.md) — [Guide](../../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::bsd::kern::maxfiles::get() {
	sysctl -n kern.maxfiles 2>/dev/null || echo "unknown"
}
```

