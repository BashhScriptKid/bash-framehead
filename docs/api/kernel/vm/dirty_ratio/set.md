# `kernel::vm::dirty_ratio::set`

**Signature:** `kernel::vm::dirty_ratio::set(arg1)`

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
kernel::vm::dirty_ratio::set() {
	runtime::is_root || { echo "kernel::vm::dirty_ratio::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/vm/dirty_ratio
}
```

