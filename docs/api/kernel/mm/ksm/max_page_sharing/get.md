# `kernel::mm::ksm::max_page_sharing::get`

**Signature:** `kernel::mm::ksm::max_page_sharing::get()`

**Module:** [`kernel`](../../../../kernel.md) — [Guide](../../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::mm::ksm::max_page_sharing::get() {
	cat /sys/kernel/mm/ksm/max_page_sharing 2>/dev/null || echo "unknown"
}
```

