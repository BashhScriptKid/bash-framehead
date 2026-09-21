# `kernel::power::disk_mode::set`

**Signature:** `kernel::power::disk_mode::set(arg1)`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
kernel::power::disk_mode::set() {
	runtime::is_root || { echo "kernel::power::disk_mode::set: requires root" >&2; return 1; }
	echo "$1" > /sys/power/disk
}
```

