# `kernel::xnu::hw::model`

**Signature:** `kernel::xnu::hw::model()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- XNU: Hardware ---


## Source

```bash
kernel::xnu::hw::model() {
	sysctl -n hw.model 2>/dev/null || echo "unknown"
}
```

