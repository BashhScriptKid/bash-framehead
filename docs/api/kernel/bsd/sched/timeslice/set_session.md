# `kernel::bsd::sched::timeslice::set_session`

**Signature:** `kernel::bsd::sched::timeslice::set_session(arg1)`

**Module:** [`kernel`](../../../../kernel.md) — [Guide](../../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
kernel::bsd::sched::timeslice::set_session() {
	runtime::is_root || { echo "kernel::bsd::sched::timeslice::set_session: requires root" >&2; return 1; }
	sysctl kern.sched.timeslice="$1" 2>/dev/null
}
```

