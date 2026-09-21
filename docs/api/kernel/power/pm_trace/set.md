# `kernel::power::pm_trace::set`

**Signature:** `kernel::power::pm_trace::set(arg1)`

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
kernel::power::pm_trace::set() {
	runtime::is_root || { echo "kernel::power::pm_trace::set: requires root" >&2; return 1; }
	echo "$1" > /sys/power/pm_trace
}
```

