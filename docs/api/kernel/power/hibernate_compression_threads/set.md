# `kernel::power::hibernate_compression_threads::set`

**Signature:** `kernel::power::hibernate_compression_threads::set(arg1)`

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
kernel::power::hibernate_compression_threads::set() {
	runtime::is_root || { echo "kernel::power::hibernate_compression_threads::set: requires root" >&2; return 1; }
	echo "$1" > /sys/power/hibernate_compression_threads
}
```

