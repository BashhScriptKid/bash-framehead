# `kernel::coredump::pattern::set`

**Signature:** `kernel::coredump::pattern::set(arg1)`

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
kernel::coredump::pattern::set() {
	runtime::is_root || { echo "kernel::coredump::pattern::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/kernel/core_pattern
}
```

