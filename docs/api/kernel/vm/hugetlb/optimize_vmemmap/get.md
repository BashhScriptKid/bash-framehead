# `kernel::vm::hugetlb::optimize_vmemmap::get`

**Signature:** `kernel::vm::hugetlb::optimize_vmemmap::get()`

**Module:** [`kernel`](../../../../kernel.md) — [Guide](../../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::vm::hugetlb::optimize_vmemmap::get() {
	cat /proc/sys/vm/hugetlb_optimize_vmemmap 2>/dev/null || echo "unknown"
}
```

