# `terminal::is_tty::stdin`

**Signature:** `terminal::is_tty::stdin()`

**Module:** [`terminal`](../../terminal.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if stdin is a terminal


## Source

```bash
terminal::is_tty::stdin() {
		[[ -t 0 ]]
}
```

