# `kernel::vm::extfrag_threshold::set`

**Signature:** `kernel::vm::extfrag_threshold::set(arg1)`

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
kernel::vm::extfrag_threshold::set() {
	runtime::is_root || { echo "kernel::vm::extfrag_threshold::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/vm/extfrag_threshold
}
```

