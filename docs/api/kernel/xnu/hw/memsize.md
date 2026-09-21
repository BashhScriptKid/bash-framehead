# `kernel::xnu::hw::memsize`

**Signature:** `kernel::xnu::hw::memsize()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::xnu::hw::memsize() {
	sysctl -n hw.memsize 2>/dev/null || echo "unknown"
}
```

