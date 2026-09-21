# `kernel::vm::movable_gigantic::set`

**Signature:** `kernel::vm::movable_gigantic::set(arg1)`

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
kernel::vm::movable_gigantic::set() {
	runtime::is_root || { echo "kernel::vm::movable_gigantic::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/vm/movable_gigantic_pages
}
```

