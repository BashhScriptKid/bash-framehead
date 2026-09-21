# `kernel::panic::timeout::get`

**Signature:** `kernel::panic::timeout::get()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::panic::timeout::get() {
	cat /proc/sys/kernel/panic 2>/dev/null || echo "unknown"
}
```

