# `kernel::xnu::power::assertions`

**Signature:** `kernel::xnu::power::assertions()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- XNU: Power ---


## Source

```bash
kernel::xnu::power::assertions() {
	pmset -g assertions 2>/dev/null || echo "unknown"
}
```

