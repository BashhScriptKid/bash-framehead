# `kernel::bsd::hw::machine`

**Signature:** `kernel::bsd::hw::machine()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::bsd::hw::machine() {
	sysctl -n hw.machine 2>/dev/null || echo "unknown"
}
```

