# `kernel::ctrl_alt_del::get`

**Signature:** `kernel::ctrl_alt_del::get()`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::ctrl_alt_del::get() {
	cat /proc/sys/kernel/ctrl-alt-del 2>/dev/null || echo "unknown"
}
```

