# `kernel::vm::movable_gigantic::get`

**Signature:** `kernel::vm::movable_gigantic::get()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::vm::movable_gigantic::get() {
	cat /proc/sys/vm/movable_gigantic_pages 2>/dev/null || echo "unknown"
}
```

