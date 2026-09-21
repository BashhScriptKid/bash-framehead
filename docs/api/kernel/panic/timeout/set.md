# `kernel::panic::timeout::set`

**Signature:** `kernel::panic::timeout::set(arg1)`

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
kernel::panic::timeout::set() {
	runtime::is_root || { echo "kernel::panic::timeout::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/kernel/panic
}
```

