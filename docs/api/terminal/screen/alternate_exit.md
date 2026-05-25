# `terminal::screen::alternate_exit`

**Signature:** `terminal::screen::alternate_exit()`

**Module:** [`terminal`](../../terminal.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
terminal::screen::alternate_exit() {
		terminal::screen::normal
		trap - EXIT INT TERM
}
```

