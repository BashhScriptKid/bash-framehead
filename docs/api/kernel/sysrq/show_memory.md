# `kernel::sysrq::show_memory`

**Signature:** `kernel::sysrq::show_memory()`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
kernel::sysrq::show_memory() {
	runtime::is_root || { echo "kernel::sysrq::show_memory: requires root" >&2; return 1; }
	echo m > /proc/sysrq-trigger
	dmesg 2>/dev/null | tail -100
}
```

