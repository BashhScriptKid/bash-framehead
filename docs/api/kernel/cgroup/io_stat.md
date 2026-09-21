# `kernel::cgroup::io_stat`

**Signature:** `kernel::cgroup::io_stat()`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::cgroup::io_stat() {
	cat /sys/fs/cgroup/io.stat 2>/dev/null || echo "unknown"
}
```

