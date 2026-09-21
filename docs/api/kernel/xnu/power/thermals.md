# `kernel::xnu::power::thermals`

**Signature:** `kernel::xnu::power::thermals()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::xnu::power::thermals() {
	pmset -g therm 2>/dev/null || echo "unknown"
}
```

