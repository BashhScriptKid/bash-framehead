# `kernel::threads_max::get`

**Signature:** `kernel::threads_max::get()`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::threads_max::get() {
	cat /proc/sys/kernel/threads-max 2>/dev/null || echo "unknown"
}
```

