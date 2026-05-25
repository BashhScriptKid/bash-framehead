# `colour::supports_256`

**Signature:** `colour::supports_256()`

**Module:** [`colour`](../colour.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if terminal supports 256 colours


## Source

```bash
colour::supports_256() {
		(( $(colour::depth) >= 256 ))
}
```

