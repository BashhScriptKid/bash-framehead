# `kernel::power::resume_offset::set`

**Signature:** `kernel::power::resume_offset::set(arg1)`

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
kernel::power::resume_offset::set() {
	runtime::is_root || { echo "kernel::power::resume_offset::set: requires root" >&2; return 1; }
	echo "$1" > /sys/power/resume_offset
}
```

