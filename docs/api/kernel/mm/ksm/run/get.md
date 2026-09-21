# `kernel::mm::ksm::run::get`

**Signature:** `kernel::mm::ksm::run::get()`

**Module:** [`kernel`](../../../../kernel.md) — [Guide](../../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::mm::ksm::run::get() {
	cat /sys/kernel/mm/ksm/run 2>/dev/null || echo "unknown"
}
```

