# `kernel::cgroup::memory_stat`

**Signature:** `kernel::cgroup::memory_stat()`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::cgroup::memory_stat() {
	cat /sys/fs/cgroup/memory.stat 2>/dev/null || echo "unknown"
}
```

