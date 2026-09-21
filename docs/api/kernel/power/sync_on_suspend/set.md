# `kernel::power::sync_on_suspend::set`

**Signature:** `kernel::power::sync_on_suspend::set(arg1)`

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
kernel::power::sync_on_suspend::set() {
	runtime::is_root || { echo "kernel::power::sync_on_suspend::set: requires root" >&2; return 1; }
	echo "$1" > /sys/power/sync_on_suspend
}
```

