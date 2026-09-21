# `kernel::security::dmesg_restrict::set`

**Signature:** `kernel::security::dmesg_restrict::set(arg1)`

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
kernel::security::dmesg_restrict::set() {
	runtime::is_root || { echo "kernel::security::dmesg_restrict::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/kernel/dmesg_restrict
}
```

