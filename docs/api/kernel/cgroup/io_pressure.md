# `kernel::cgroup::io_pressure`

**Signature:** `kernel::cgroup::io_pressure()`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::cgroup::io_pressure() {
	cat /sys/fs/cgroup/io.pressure 2>/dev/null || echo "unknown"
}
```

