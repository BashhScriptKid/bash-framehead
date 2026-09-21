# `kernel::sysrq::sync`

**Signature:** `kernel::sysrq::sync()`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
kernel::sysrq::sync() {
	runtime::is_root || { echo "kernel::sysrq::sync: requires root" >&2; return 1; }
	echo s > /proc/sysrq-trigger
}
```

