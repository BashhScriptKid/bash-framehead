# `terminal::screen::alternate_enter`

**Signature:** `terminal::screen::alternate_enter()`

**Module:** [`terminal`](../../terminal.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
terminal::screen::alternate_enter() {
		terminal::screen::alternate
		terminal::cursor::home
		terminal::clear
		trap 'terminal::screen::normal' EXIT INT TERM
}
```

