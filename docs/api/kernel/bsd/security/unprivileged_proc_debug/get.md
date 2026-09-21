# `kernel::bsd::security::unprivileged_proc_debug::get`

**Signature:** `kernel::bsd::security::unprivileged_proc_debug::get()`

**Module:** [`kernel`](../../../../kernel.md) — [Guide](../../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- BSD: Security ---


## Source

```bash
kernel::bsd::security::unprivileged_proc_debug::get() {
	sysctl -n security.bsd.unprivileged_proc_debug 2>/dev/null || echo "unknown"
}
```

