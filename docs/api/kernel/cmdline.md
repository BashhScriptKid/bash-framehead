# `kernel::cmdline`

**Signature:** `kernel::cmdline()`

**Module:** [`kernel`](../kernel.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- LINUX-ONLY IDENTITY ---


## Source

```bash
kernel::cmdline() {
	cat /proc/cmdline 2>/dev/null || echo "unknown"
}
```

