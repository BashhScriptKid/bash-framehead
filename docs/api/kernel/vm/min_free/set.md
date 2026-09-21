# `kernel::vm::min_free::set`

**Signature:** `kernel::vm::min_free::set(arg1)`

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
kernel::vm::min_free::set() {
	runtime::is_root || { echo "kernel::vm::min_free::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/vm/min_free_kbytes
}
```

