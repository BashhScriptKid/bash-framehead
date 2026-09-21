# `kernel::pid_max::get`

**Signature:** `kernel::pid_max::get()`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- /proc/sys/kernel TUNABLES ---


## Source

```bash
kernel::pid_max::get() {
	cat /proc/sys/kernel/pid_max 2>/dev/null || echo "unknown"
}
```

