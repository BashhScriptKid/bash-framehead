# `kernel::vm::max_map_count::get`

**Signature:** `kernel::vm::max_map_count::get()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::vm::max_map_count::get() {
	cat /proc/sys/vm/max_map_count 2>/dev/null || echo "unknown"
}
```

