# `kernel::xnu::hw::ncpu`

**Signature:** `kernel::xnu::hw::ncpu()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::xnu::hw::ncpu() {
	sysctl -n hw.ncpu 2>/dev/null || echo "unknown"
}
```

