# `kernel::bsd::sched::topology`

**Signature:** `kernel::bsd::sched::topology()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- BSD: Scheduler ---


## Source

```bash
kernel::bsd::sched::topology() {
	sysctl -n kern.sched.topology_spec 2>/dev/null || echo "unknown"
}
```

