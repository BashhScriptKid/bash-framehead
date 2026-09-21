# `kernel::xnu::swvers::build`

**Signature:** `kernel::xnu::swvers::build()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::xnu::swvers::build() {
	sw_vers -buildVersion 2>/dev/null || echo "unknown"
}
```

