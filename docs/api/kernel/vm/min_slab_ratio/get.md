# `kernel::vm::min_slab_ratio::get`

**Signature:** `kernel::vm::min_slab_ratio::get()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::vm::min_slab_ratio::get() {
	cat /proc/sys/vm/min_slab_ratio 2>/dev/null || echo "unknown"
}
```

