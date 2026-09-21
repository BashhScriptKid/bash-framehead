# `kernel::xnu::hw::pagesize`

**Signature:** `kernel::xnu::hw::pagesize()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::xnu::hw::pagesize() {
	sysctl -n hw.pagesize 2>/dev/null || echo "unknown"
}
```

