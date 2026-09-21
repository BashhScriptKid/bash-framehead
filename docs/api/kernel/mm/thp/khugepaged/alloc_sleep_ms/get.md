# `kernel::mm::thp::khugepaged::alloc_sleep_ms::get`

**Signature:** `kernel::mm::thp::khugepaged::alloc_sleep_ms::get()`

**Module:** [`kernel`](../../../../../kernel.md) — [Guide](../../../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::mm::thp::khugepaged::alloc_sleep_ms::get() {
	cat /sys/kernel/mm/transparent_hugepage/khugepaged/alloc_sleep_millisecs 2>/dev/null || echo "unknown"
}
```

