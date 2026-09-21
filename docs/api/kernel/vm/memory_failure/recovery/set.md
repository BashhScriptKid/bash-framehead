# `kernel::vm::memory_failure::recovery::set`

**Signature:** `kernel::vm::memory_failure::recovery::set(arg1)`

**Module:** [`kernel`](../../../../kernel.md) — [Guide](../../../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
kernel::vm::memory_failure::recovery::set() {
	runtime::is_root || { echo "kernel::vm::memory_failure::recovery::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/vm/memory_failure_recovery
}
```

