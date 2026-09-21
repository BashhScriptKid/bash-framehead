# `kernel::vm::soft_offline::set`

**Signature:** `kernel::vm::soft_offline::set(arg1)`

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
kernel::vm::soft_offline::set() {
	runtime::is_root || { echo "kernel::vm::soft_offline::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/vm/enable_soft_offline
}
```

