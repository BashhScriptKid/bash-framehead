# `kernel::power::hibernate`

**Signature:** `kernel::power::hibernate()`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
kernel::power::hibernate() {
	runtime::is_root || { echo "kernel::power::hibernate: requires root" >&2; return 1; }
	echo disk > /sys/power/state
}
```

