# `kernel::mm::ksm::use_zero_pages::get`

**Signature:** `kernel::mm::ksm::use_zero_pages::get()`

**Module:** [`kernel`](../../../../kernel.md) — [Guide](../../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::mm::ksm::use_zero_pages::get() {
	cat /sys/kernel/mm/ksm/use_zero_pages 2>/dev/null || echo "unknown"
}
```

