# `kernel::vm::swappiness::get`

**Signature:** `kernel::vm::swappiness::get()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::vm::swappiness::get() {
	cat /proc/sys/vm/swappiness 2>/dev/null || echo "unknown"
}
```

