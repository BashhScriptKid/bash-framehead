# `kernel::bsd::sched::timeslice::get`

**Signature:** `kernel::bsd::sched::timeslice::get()`

**Module:** [`kernel`](../../../../kernel.md) — [Guide](../../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::bsd::sched::timeslice::get() {
	sysctl -n kern.sched.timeslice 2>/dev/null || echo "unknown"
}
```

