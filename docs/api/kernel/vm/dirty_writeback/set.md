# `kernel::vm::dirty_writeback::set`

**Signature:** `kernel::vm::dirty_writeback::set(arg1)`

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
kernel::vm::dirty_writeback::set() {
	runtime::is_root || { echo "kernel::vm::dirty_writeback::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/vm/dirty_writeback_centisecs
}
```

