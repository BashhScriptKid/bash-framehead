# `kernel::power::image_size::set`

**Signature:** `kernel::power::image_size::set(arg1)`

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
kernel::power::image_size::set() {
	runtime::is_root || { echo "kernel::power::image_size::set: requires root" >&2; return 1; }
	echo "$1" > /sys/power/image_size
}
```

