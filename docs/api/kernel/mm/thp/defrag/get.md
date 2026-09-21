# `kernel::mm::thp::defrag::get`

**Signature:** `kernel::mm::thp::defrag::get()`

**Module:** [`kernel`](../../../../kernel.md) — [Guide](../../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::mm::thp::defrag::get() {
	cat /sys/kernel/mm/transparent_hugepage/defrag 2>/dev/null || echo "unknown"
}
```

