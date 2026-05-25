# `terminal::has_colour`

**Signature:** `terminal::has_colour()`

**Module:** [`terminal`](../terminal.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if terminal supports colours


## Source

```bash
terminal::has_colour() {
		[[ -t 1 ]] && (( $(tput colors 2>/dev/null) >= 8 ))
}
```

