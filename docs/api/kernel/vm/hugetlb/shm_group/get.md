# `kernel::vm::hugetlb::shm_group::get`

**Signature:** `kernel::vm::hugetlb::shm_group::get()`

**Module:** [`kernel`](../../../../kernel.md) — [Guide](../../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::vm::hugetlb::shm_group::get() {
	cat /proc/sys/vm/hugetlb_shm_group 2>/dev/null || echo "unknown"
}
```

