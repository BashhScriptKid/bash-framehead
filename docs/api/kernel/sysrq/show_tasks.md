# `kernel::sysrq::show_tasks`

**Signature:** `kernel::sysrq::show_tasks()`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
kernel::sysrq::show_tasks() {
	runtime::is_root || { echo "kernel::sysrq::show_tasks: requires root" >&2; return 1; }
	echo t > /proc/sysrq-trigger
	dmesg 2>/dev/null | tail -100
}
```

