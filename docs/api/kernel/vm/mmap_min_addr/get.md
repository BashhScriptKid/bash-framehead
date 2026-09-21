# `kernel::vm::mmap_min_addr::get`

**Signature:** `kernel::vm::mmap_min_addr::get()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::vm::mmap_min_addr::get() {
	cat /proc/sys/vm/mmap_min_addr 2>/dev/null || echo "unknown"
}
```

