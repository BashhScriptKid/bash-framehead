# `kernel::power::mem_sleep::set`

**Signature:** `kernel::power::mem_sleep::set(arg1)`

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
kernel::power::mem_sleep::set() {
	runtime::is_root || { echo "kernel::power::mem_sleep::set: requires root" >&2; return 1; }
	echo "$1" > /sys/power/mem_sleep
}
```

