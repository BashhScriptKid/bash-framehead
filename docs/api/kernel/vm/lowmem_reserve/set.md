# `kernel::vm::lowmem_reserve::set`

**Signature:** `kernel::vm::lowmem_reserve::set(arg1)`

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
kernel::vm::lowmem_reserve::set() {
	runtime::is_root || { echo "kernel::vm::lowmem_reserve::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/vm/lowmem_reserve_ratio
}
```

