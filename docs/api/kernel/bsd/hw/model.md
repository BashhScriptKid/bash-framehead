# `kernel::bsd::hw::model`

**Signature:** `kernel::bsd::hw::model()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- BSD: Hardware ---


## Source

```bash
kernel::bsd::hw::model() {
	sysctl -n hw.model 2>/dev/null || echo "unknown"
}
```

