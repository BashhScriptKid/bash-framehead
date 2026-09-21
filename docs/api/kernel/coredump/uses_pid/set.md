# `kernel::coredump::uses_pid::set`

**Signature:** `kernel::coredump::uses_pid::set(arg1)`

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
kernel::coredump::uses_pid::set() {
	runtime::is_root || { echo "kernel::coredump::uses_pid::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/kernel/core_uses_pid
}
```

