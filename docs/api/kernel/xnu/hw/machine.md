# `kernel::xnu::hw::machine`

**Signature:** `kernel::xnu::hw::machine()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::xnu::hw::machine() {
	sysctl -n hw.machine 2>/dev/null || echo "unknown"
}
```

