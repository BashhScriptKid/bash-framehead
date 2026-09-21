# `kernel::ftrace::dump_on_oops::set`

**Signature:** `kernel::ftrace::dump_on_oops::set(arg1)`

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
kernel::ftrace::dump_on_oops::set() {
	runtime::is_root || { echo "kernel::ftrace::dump_on_oops::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/kernel/ftrace_dump_on_oops
}
```

