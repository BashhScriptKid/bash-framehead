# `kernel::vm::vfs_cache_pressure::set`

**Signature:** `kernel::vm::vfs_cache_pressure::set(arg1)`

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
kernel::vm::vfs_cache_pressure::set() {
	runtime::is_root || { echo "kernel::vm::vfs_cache_pressure::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/vm/vfs_cache_pressure
}
```

