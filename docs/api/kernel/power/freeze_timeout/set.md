# `kernel::power::freeze_timeout::set`

**Signature:** `kernel::power::freeze_timeout::set(arg1)`

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
kernel::power::freeze_timeout::set() {
	runtime::is_root || { echo "kernel::power::freeze_timeout::set: requires root" >&2; return 1; }
	echo "$1" > /sys/power/pm_freeze_timeout
}
```

