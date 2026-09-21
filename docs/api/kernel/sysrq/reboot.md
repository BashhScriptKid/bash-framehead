# `kernel::sysrq::reboot`

**Signature:** `kernel::sysrq::reboot()`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
kernel::sysrq::reboot() {
	runtime::is_root || { echo "kernel::sysrq::reboot: requires root" >&2; return 1; }
	echo b > /proc/sysrq-trigger
}
```

