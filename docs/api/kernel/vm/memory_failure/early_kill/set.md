# `kernel::vm::memory_failure::early_kill::set`

**Signature:** `kernel::vm::memory_failure::early_kill::set(arg1)`

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
kernel::vm::memory_failure::early_kill::set() {
	runtime::is_root || { echo "kernel::vm::memory_failure::early_kill::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/vm/memory_failure_early_kill
}
```

