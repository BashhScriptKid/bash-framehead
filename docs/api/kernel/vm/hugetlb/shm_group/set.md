# `kernel::vm::hugetlb::shm_group::set`

**Signature:** `kernel::vm::hugetlb::shm_group::set(arg1)`

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
kernel::vm::hugetlb::shm_group::set() {
	runtime::is_root || { echo "kernel::vm::hugetlb::shm_group::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/vm/hugetlb_shm_group
}
```

