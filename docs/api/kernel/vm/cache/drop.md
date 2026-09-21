# `kernel::vm::cache::drop`

**Signature:** `kernel::vm::cache::drop(arg1)`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** stdout — prints result

## Description

--- /proc/sys/vm TUNABLES ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
kernel::vm::cache::drop() {
	runtime::is_root || { echo "kernel::vm::cache::drop: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/vm/drop_caches
}
```

