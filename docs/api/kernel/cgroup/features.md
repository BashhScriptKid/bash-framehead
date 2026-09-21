# `kernel::cgroup::features`

**Signature:** `kernel::cgroup::features()`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- CGROUP ---


## Source

```bash
kernel::cgroup::features() {
	cat /sys/kernel/cgroup/features 2>/dev/null || echo "unknown"
}
```

