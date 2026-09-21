# `kernel::mm::thp::khugepaged::defrag::get`

**Signature:** `kernel::mm::thp::khugepaged::defrag::get()`

**Module:** [`kernel`](../../../../../kernel.md) — [Guide](../../../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::mm::thp::khugepaged::defrag::get() {
	cat /sys/kernel/mm/transparent_hugepage/khugepaged/defrag 2>/dev/null || echo "unknown"
}
```

