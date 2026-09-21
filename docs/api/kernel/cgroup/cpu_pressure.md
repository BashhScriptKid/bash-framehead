# `kernel::cgroup::cpu_pressure`

**Signature:** `kernel::cgroup::cpu_pressure()`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::cgroup::cpu_pressure() {
	cat /sys/fs/cgroup/cpu.pressure 2>/dev/null || echo "unknown"
}
```

