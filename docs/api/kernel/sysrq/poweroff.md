# `kernel::sysrq::poweroff`

**Signature:** `kernel::sysrq::poweroff()`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
kernel::sysrq::poweroff() {
	runtime::is_root || { echo "kernel::sysrq::poweroff: requires root" >&2; return 1; }
	echo o > /proc/sysrq-trigger
}
```

