# `kernel::bpf::stats_enabled::get`

**Signature:** `kernel::bpf::stats_enabled::get()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::bpf::stats_enabled::get() {
	cat /proc/sys/kernel/bpf_stats_enabled 2>/dev/null || echo "unknown"
}
```

