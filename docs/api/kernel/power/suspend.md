# `kernel::power::suspend`

**Signature:** `kernel::power::suspend()`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
kernel::power::suspend() {
	runtime::is_root || { echo "kernel::power::suspend: requires root" >&2; return 1; }
	echo mem > /sys/power/state
}
```

