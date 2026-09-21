# `kernel::xnu::swvers::version`

**Signature:** `kernel::xnu::swvers::version()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::xnu::swvers::version() {
	sw_vers -productVersion 2>/dev/null || echo "unknown"
}
```

