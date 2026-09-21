# `kernel::cgroup::delegate`

**Signature:** `kernel::cgroup::delegate()`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::cgroup::delegate() {
	cat /sys/kernel/cgroup/delegate 2>/dev/null || echo "unknown"
}
```

