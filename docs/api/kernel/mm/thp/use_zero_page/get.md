# `kernel::mm::thp::use_zero_page::get`

**Signature:** `kernel::mm::thp::use_zero_page::get()`

**Module:** [`kernel`](../../../../kernel.md) — [Guide](../../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::mm::thp::use_zero_page::get() {
	cat /sys/kernel/mm/transparent_hugepage/use_zero_page 2>/dev/null || echo "unknown"
}
```

