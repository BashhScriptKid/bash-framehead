# `kernel::power::debug_messages::set`

**Signature:** `kernel::power::debug_messages::set(arg1)`

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
kernel::power::debug_messages::set() {
	runtime::is_root || { echo "kernel::power::debug_messages::set: requires root" >&2; return 1; }
	echo "$1" > /sys/power/pm_debug_messages
}
```

