# `kernel::vm::mmap_rnd_bits::get`

**Signature:** `kernel::vm::mmap_rnd_bits::get()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::vm::mmap_rnd_bits::get() {
	cat /proc/sys/vm/mmap_rnd_bits 2>/dev/null || echo "unknown"
}
```

