# `kernel::mm::thp::khugepaged::pages_to_scan::get`

**Signature:** `kernel::mm::thp::khugepaged::pages_to_scan::get()`

**Module:** [`kernel`](../../../../../kernel.md) — [Guide](../../../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::mm::thp::khugepaged::pages_to_scan::get() {
	cat /sys/kernel/mm/transparent_hugepage/khugepaged/pages_to_scan 2>/dev/null || echo "unknown"
}
```

