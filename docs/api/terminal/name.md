# `terminal::name`

**Signature:** `terminal::name()`

**Module:** [`terminal`](../terminal.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Return the terminal emulator name if detectable


## Source

```bash
terminal::name() {
		if [[ -n "$TERM_PROGRAM" ]]; then
				echo "$TERM_PROGRAM"
		elif [[ -n "$TERMINAL" ]]; then
				echo "$TERMINAL"
		elif [[ -n "$TERM" ]]; then
				echo "$TERM"
		else
				echo "unknown"
		fi
}
```

