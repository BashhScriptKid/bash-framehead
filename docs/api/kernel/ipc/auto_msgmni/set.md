# `kernel::ipc::auto_msgmni::set`

**Signature:** `kernel::ipc::auto_msgmni::set(arg1)`

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
kernel::ipc::auto_msgmni::set() {
	runtime::is_root || { echo "kernel::ipc::auto_msgmni::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/kernel/auto_msgmni
}
```

