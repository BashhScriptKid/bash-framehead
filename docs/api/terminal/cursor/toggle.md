# `terminal::cursor::toggle`

**Signature:** `terminal::cursor::toggle()`

**Module:** [`terminal`](../../terminal.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
terminal::cursor::toggle() {
		# Tracks state via a global flag
		if [[ "${_TERMINAL_CURSOR_HIDDEN:-0}" == "1" ]]; then
				terminal::cursor::show
				_TERMINAL_CURSOR_HIDDEN=0
		else
				terminal::cursor::hide
				_TERMINAL_CURSOR_HIDDEN=1
		fi
}
```

