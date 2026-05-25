# `terminal::height`

**Signature:** `terminal::height()`

**Module:** [`terminal`](../terminal.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Get terminal height in rows


## Source

```bash
terminal::height() {
		tput lines 2>/dev/null || echo "24"
}
```

