# `terminal::screen::wrap`

**Signature:** `terminal::screen::wrap(command, [args...])`

**Module:** [`terminal`](../../terminal.md) — [Guide](../../guide/index.md)

**Return:** exit code

## Description

Enter alternate screen, run a command, return to normal screen

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `command` | command | Yes | |
| `args...` | string | No | |

## Source

```bash
terminal::screen::wrap() {
		terminal::screen::alternate
		"$@"
		local ret=$?
		terminal::screen::normal
		return $ret
}
```

