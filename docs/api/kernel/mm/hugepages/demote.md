# `kernel::mm::hugepages::demote`

**Signature:** `kernel::mm::hugepages::demote()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
kernel::mm::hugepages::demote() {
	runtime::is_root || { echo "kernel::mm::hugepages::demote: requires root" >&2; return 1; }
	echo 1 > /sys/kernel/mm/hugepages/hugepages-2048kB/demote 2>/dev/null
}
```

