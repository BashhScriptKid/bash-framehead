# `kernel::vm::compact_unevictable::get`

**Signature:** `kernel::vm::compact_unevictable::get()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::vm::compact_unevictable::get() {
	cat /proc/sys/vm/compact_unevictable_allowed 2>/dev/null || echo "unknown"
}
```

