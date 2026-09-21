# `kernel::mm::thp::use_zero_page::set`

**Signature:** `kernel::mm::thp::use_zero_page::set(arg1)`

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
kernel::mm::thp::use_zero_page::set() {
	runtime::is_root || { echo "kernel::mm::thp::use_zero_page::set: requires root" >&2; return 1; }
	echo "$1" > /sys/kernel/mm/transparent_hugepage/use_zero_page
}
```

