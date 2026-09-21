# `kernel::xnu::hw::cpufrequency`

**Signature:** `kernel::xnu::hw::cpufrequency()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::xnu::hw::cpufrequency() {
	sysctl -n hw.cpufrequency 2>/dev/null || echo "unknown"
}
```

