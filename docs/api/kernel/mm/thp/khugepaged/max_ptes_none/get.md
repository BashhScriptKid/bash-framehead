# `kernel::mm::thp::khugepaged::max_ptes_none::get`

**Signature:** `kernel::mm::thp::khugepaged::max_ptes_none::get()`

**Module:** [`kernel`](../../../../../kernel.md) — [Guide](../../../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::mm::thp::khugepaged::max_ptes_none::get() {
	cat /sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_none 2>/dev/null || echo "unknown"
}
```

