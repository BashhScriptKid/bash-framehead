# `kernel::vm::hugetlb::optimize_vmemmap::set`

**Signature:** `kernel::vm::hugetlb::optimize_vmemmap::set(arg1)`

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
kernel::vm::hugetlb::optimize_vmemmap::set() {
	runtime::is_root || { echo "kernel::vm::hugetlb::optimize_vmemmap::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/vm/hugetlb_optimize_vmemmap
}
```

