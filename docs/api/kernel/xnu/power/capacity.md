# `kernel::xnu::power::capacity`

**Signature:** `kernel::xnu::power::capacity()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::xnu::power::capacity() {
	pmset -g batt 2>/dev/null || echo "unknown"
}
```

