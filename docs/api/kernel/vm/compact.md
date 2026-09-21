# `kernel::vm::compact`

**Signature:** `kernel::vm::compact()`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
kernel::vm::compact() {
	runtime::is_root || { echo "kernel::vm::compact: requires root" >&2; return 1; }
	echo 1 > /proc/sys/vm/compact_memory
}
```

