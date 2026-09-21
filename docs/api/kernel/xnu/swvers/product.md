# `kernel::xnu::swvers::product`

**Signature:** `kernel::xnu::swvers::product()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- XNU: macOS Version ---


## Source

```bash
kernel::xnu::swvers::product() {
	sw_vers -productName 2>/dev/null || echo "unknown"
}
```

