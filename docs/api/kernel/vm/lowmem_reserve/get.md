# `kernel::vm::lowmem_reserve::get`

**Signature:** `kernel::vm::lowmem_reserve::get()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::vm::lowmem_reserve::get() {
	cat /proc/sys/vm/lowmem_reserve_ratio 2>/dev/null || echo "unknown"
}
```

