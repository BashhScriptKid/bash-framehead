# `kernel::coredump::sort_vma::set`

**Signature:** `kernel::coredump::sort_vma::set(arg1)`

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
kernel::coredump::sort_vma::set() {
	runtime::is_root || { echo "kernel::coredump::sort_vma::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/kernel/core_sort_vma
}
```

