# `kernel::mm::ksm::advisor_scan_time::get`

**Signature:** `kernel::mm::ksm::advisor_scan_time::get()`

**Module:** [`kernel`](../../../../kernel.md) — [Guide](../../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::mm::ksm::advisor_scan_time::get() {
	cat /sys/kernel/mm/ksm/advisor_target_scan_time 2>/dev/null || echo "unknown"
}
```

