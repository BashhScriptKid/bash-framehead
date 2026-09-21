# `kernel::mm::thp::defrag::set`

**Signature:** `kernel::mm::thp::defrag::set(arg1)`

**Module:** [`kernel`](../../../../kernel.md) — [Guide](../../../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
kernel::mm::thp::defrag::set() {
	runtime::is_root || { echo "kernel::mm::thp::defrag::set: requires root" >&2; return 1; }
	echo "$1" > /sys/kernel/mm/transparent_hugepage/defrag
}
```

