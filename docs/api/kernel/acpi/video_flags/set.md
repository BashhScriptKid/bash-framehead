# `kernel::acpi::video_flags::set`

**Signature:** `kernel::acpi::video_flags::set(arg1)`

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
kernel::acpi::video_flags::set() {
	runtime::is_root || { echo "kernel::acpi::video_flags::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/kernel/acpi_video_flags
}
```

