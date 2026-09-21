# `kernel::bsd::hw::clockrate`

**Signature:** `kernel::bsd::hw::clockrate()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::bsd::hw::clockrate() {
	sysctl -n hw.clockrate 2>/dev/null || sysctl -n hw.cpuspeed 2>/dev/null || echo "unknown"
}
```

