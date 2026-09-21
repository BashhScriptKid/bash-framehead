# `kernel::bsd::kern::maxproc::get`

**Signature:** `kernel::bsd::kern::maxproc::get()`

**Module:** [`kernel`](../../../../kernel.md) — [Guide](../../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- BSD: Kernel Tunables ---


## Source

```bash
kernel::bsd::kern::maxproc::get() {
	sysctl -n kern.maxproc 2>/dev/null || echo "unknown"
}
```

