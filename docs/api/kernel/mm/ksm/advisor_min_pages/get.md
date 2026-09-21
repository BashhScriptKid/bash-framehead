# `kernel::mm::ksm::advisor_min_pages::get`

**Signature:** `kernel::mm::ksm::advisor_min_pages::get()`

**Module:** [`kernel`](../../../../kernel.md) — [Guide](../../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::mm::ksm::advisor_min_pages::get() {
	cat /sys/kernel/mm/ksm/advisor_min_pages_to_scan 2>/dev/null || echo "unknown"
}
```

