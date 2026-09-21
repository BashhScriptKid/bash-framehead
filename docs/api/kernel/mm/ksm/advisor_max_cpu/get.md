# `kernel::mm::ksm::advisor_max_cpu::get`

**Signature:** `kernel::mm::ksm::advisor_max_cpu::get()`

**Module:** [`kernel`](../../../../kernel.md) — [Guide](../../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::mm::ksm::advisor_max_cpu::get() {
	cat /sys/kernel/mm/ksm/advisor_max_cpu 2>/dev/null || echo "unknown"
}
```

