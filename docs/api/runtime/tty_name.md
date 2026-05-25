# `runtime::tty_name`

**Signature:** `runtime::tty_name()`

**Module:** [`runtime`](../runtime.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
runtime::tty_name() {
	tty 2>/dev/null || echo "not a tty"
}
```

